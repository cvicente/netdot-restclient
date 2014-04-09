require 'netdot/restclient/version'

require 'httpclient'

module Netdot
  class RestClient    
    attr_accessor :format, :base_url, :ua, :xs

    # Constructor and login method
    #
    # Arguments (hash):
    #
    # server   - Netdot server URL
    # username - Netdot Username
    # password - Netdot password
    # retries  - Number of attempts
    # timeout  - Timeout in seconds
    # format   - Content format <xml>
    #
    # Returns:
    #   Netdot::RestClient object
    # Example:
    #   Netdot::Restclient.new(args)
    #
    def initialize(argv = {})
      
      [:server, :username, :password].each do |k|
        raise ArgumentError, "Missing required argument '#{k}'" unless argv[k]
      end
      
      argv.each { |k,v| instance_variable_set("@#{k}", v) }
      
      @timeout ||= 10
      @retries ||= 3
      @format  ||= 'xml'
      
      if ( @format == 'xml' ) 
        begin
          require 'xmlsimple'
        rescue LoadError => e
          raise LoadError, "Cannot load XML library. Try running 'gem install xml-simple'"
        end
        xs = XmlSimple.new({ 'ForceArray' => true, 'KeyAttr' => 'id'})
        @xs = xs
      else
        raise ArgumentError, "Only XML formatting supported at this time"
      end

      ua = HTTPClient.new(:agent_name => "Netdot::RestClient/#{self.version}")
      ua.set_cookie_store("cookie.dat")

      login_url = @server + '/NetdotLogin'
      
      resp = nil

      @retries.times do
        resp = ua.post login_url, {
          'destination'       => 'index.html',
          'credential_0'      => @username,
          'credential_1'      => @password,
          'permanent_session' => 1,
        }
        if resp 
          ua.save_cookie_store
          @ua = ua
          @base_url = @server + '/rest'
          break
        else
          $stderr.puts "Connection attempt to #{@server} failed"
        end
      end
      
      raise "Could not log into #{@server}" unless resp

    end
    

    # Build the Extra headers
    #
    def extheader
      { 'Accept' => 'text/' + self.format + '; version=1.0' }
    end

    # Build URL given a resource
    #
    def build_url(resource)
      self.base_url + '/' + resource
    end

    # Get a resource
    #
    # Arguments:
    #   resource - A URI
    # Returns:
    #   hash when successful
    #   exception when not
    def get(resource)
      url = self.build_url(resource)
      resp = self.ua.get(url, nil, self.extheader)
      if ( resp.status == 200 )
        self.xs.xml_in(resp.content)
      else
        raise "Could not get #{url}: #{resp.status}" 
      end
    end


    # Update or create a resource
    # 
    # Arguments:
    #   resource - A URI
    #   data     - Hash with key/values
    # Returns:
    #   new or modified record hash when successful
    #   exception when not
    def post(resource, data)
      url = self.build_url(resource)
      raise ArgumentError, "Data must be hash" unless data.is_a?(Hash)
      resp = self.ua.post(url, data, self.extheader)
      if ( resp.status == 200 )
        self.xs.xml_in(resp.content)
      else
        raise "Could not post to #{url}: #{resp.status}"
      end
    end


    # Delete a resource
    # 
    # Arguments:
    #   resource - A URI
    #   
    # Returns:
    #   true when successful
    #   exception when not
    #
    def delete(resource)
      url = self.build_url(resource)
      resp = self.ua.delete(url, nil, self.extheader)
      if ( resp.status == 200 )
        return true
      else
        raise "Could not delete #{url}: #{resp.status}"
      end

    end

  end
end
