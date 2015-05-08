require 'netdot/restclient/version'

require 'httpclient'

# Netdot
module Netdot
  # Manage RestClient objects.
  class RestClient
    attr_accessor :format, :base_url, :ua, :xs

    # Constructor and login method
    # @param :server [String] Netdot server URL
    # @param :username [String] Netdot Username
    # @param :password [String] Netdot password
    # @param :retries [String] (optional) Number of attempts
    # @param :timeout [String] (optional) Timeout in seconds
    # @param :format [String] (optional) Content format <xml>
    # @param :ssl_version [String] (optional) Specify version of SSL;
    #   see HTTPClient
    # @param :ssl_verify [String] (optional) Verify server cert (default: yes)
    # @param :ssl_ca_file [String] (optional) Path to SSL CA cert file
    # @param :ssl_ca_dir [String] (optional) Path to SSL CA cert directory
    # @param :cookie_file [String] (optional) Cookie filename
    def initialize(argv = {})
      [:server, :username, :password].each do |k|
        fail ArgumentError, "Missing required argument '#{k}'" unless argv[k]
      end

      argv.each { |k, v| instance_variable_set("@#{k}", v) }

      @timeout ||= 10
      @retries ||= 3
      @format ||= 'xml'
      @cookie_file ||= './cookie.dat'
      defined?(@ssl_verify) || @ssl_verify = true

      if (@format == 'xml')
        begin
          require 'xmlsimple'
        rescue LoadError
          raise LoadError,
                "Cannot load XML library. Try running 'gem install xml-simple'"
        end
        xs = XmlSimple.new('ForceArray' => true, 'KeyAttr' => 'id')
        @xs = xs
      else
        fail ArgumentError, 'Only XML formatting supported at this time'
      end

      ua = HTTPClient.new(agent_name: "Netdot::RestClient/#{version}")
      ua.set_cookie_store("#{@cookie_file}")

      # SSL stuff
      if @ssl_verify
        if @ssl_ca_dir
          # We are told to add a certs path
          # We'll want to clear the default cert store first
          ua.ssl_config.clear_cert_store
          ua.ssl_config.set_trust_ca(@ssl_ca_dir)
        elsif @ssl_ca_file
          ua.ssl_config.set_trust_ca(@ssl_ca_file)
        end
      else
        ua.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      # If version given, set it
      ua.ssl_config.ssl_version = @ssl_version if @ssl_version

      login_url = @server + '/NetdotLogin'

      resp = nil

      @retries.times do
        resp = ua.post login_url,
                       'destination'       => 'index.html',
                       'credential_0'      => @username,
                       'credential_1'      => @password,
                       'permanent_session' => 1

        if (resp.status == 302)
          ua.save_cookie_store
          @ua = ua
          @base_url = @server + '/rest'
          break
        else
          $stderr.puts "Warning: Connection attempt to #{@server} failed"
        end
      end

      return if (resp.status == 302)
      fail "Could not log into #{@server}. Status Code: '#{resp.status}'"
    end

    # Builds the Extra headers.
    def extheader
      { 'Accept' => 'text/' + format + '; version=1.0' }
    end

    # Builds a URL for the specified resource.
    # @param [String] resource a URI
    def build_url(resource)
      base_url + '/' + resource
    end

    # Gets a resource.
    # @param [String] resource a URI
    # @return [Hash] hash when successful; exception when not
    def get(resource)
      url = build_url(resource)
      resp = ua.get(url, nil, extheader)
      if (resp.status == 200)
        xs.xml_in(resp.content)
      else
        fail "Could not get #{url}: #{resp.status}"
      end
    end

    # Updates or creates a resource.
    # @param [String] resource a URI
    # @param [Hash] data
    # @return [Hash] new or modified record hash when successful; exception
    #   when not
    def post(resource, data)
      url = build_url(resource)
      fail ArgumentError, 'Data must be hash' unless data.is_a?(Hash)
      resp = ua.post(url, data, extheader)
      if (resp.status == 200)
        xs.xml_in(resp.content)
      else
        fail "Could not post to #{url}: #{resp.status}"
      end
    end

    # Deletes a resource.
    # @param [String] resource a URI
    # @return [Truth] true when successful; exception when not
    def delete(resource)
      url = build_url(resource)
      resp = ua.delete(url, nil, extheader)
      if (resp.status == 200)
        return true
      else
        fail "Could not delete #{url}: #{resp.status}"
      end
    end
  end
end
