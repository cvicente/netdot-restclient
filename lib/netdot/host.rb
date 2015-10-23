# Netdot
module Netdot
  # Manage Host objects.
  class Host
    attr_accessor :connection

    # Constructor
    # @option argv [Hash] :connection (REQUIRED) a Netdot::RestClient object
    def initialize(argv = {})
      [:connection].each do |k|
        fail ArgumentError, "Missing required argument '#{k}'" unless argv[k]
      end

      argv.each { |k, v| instance_variable_set("@#{k}", v) }
    end

    # Finds all RR and Ipblock records, given a flexible set of arguments.
    # Handles NOT FOUND exceptions.
    # @param param [String] a generic parameter
    # @param value [String] a generic value
    def find(param, value)
      begin
        host = @connection.get("/host?#{param}=#{value}")
      rescue => e
        # Not Found is ok, otherwise re-raise
        raise unless e.message =~ /404/
      end
      # Return what we got
      host
    end

    # Finds all RR and Ipblock records associated with the specified name.
    # @param name [String]
    def find_by_name(name)
      find(:name, name)
    end

    # Finds all RR and Ipblock records associated with the specified IP.
    # @param ip [String]
    def find_by_ip(ip)
      find(:address, ip)
    end

    # Creates a DNS A record for the specified name and IP.
    # Will also create PTR record if .arpa zone exists.
    # @param name [String]
    # @param ip [String]
    def create(name, ip)
      Netdot.logger.debug("Creating new DNS records with name:#{name}" \
      " and ip:#{ip}")
      @connection.post('host', 'name' => name, 'address' => ip)
    end

    # Creates a DNS A record for the specified name, using the next
    # available IP address in the given subnet.
    # Will also create PTR record if .arpa zone exists.
    # @param name [String]
    # @param subnet [String]
    # @return [String] IP address allocated
    def create_next(name, subnet)
      Netdot.logger.debug("Creating new DNS records with name:#{name}" \
      " and in subnet:#{subnet}")
      host = @connection.post('host', 'name' => name, 'subnet' => subnet)
      pp host
      r = find_by_name(host['name'])
      ipid = r["Ipblock"].keys.first
      r["Ipblock"][ipid]["address"]
    end

    # Updates the DNS A record for the sepcified name and IP.
    # Will also create PTR record if .arpa zone exists.
    # @param name [String]
    # @param ip [String]
    def update(name, ip)
      Netdot.logger.debug("Updating DNS records with name:#{name} and ip:#{ip}")
      delete(name)
      create(name, ip)
    end

    # Deletes the DNS A record for the specified name.
    # @param name [String]
    def delete(name)
      host = find_by_name(name)
      return unless host

      # remove any associated IP addresses
      Netdot.logger.debug("Removing IP records for #{name}")
      host['Ipblock'].keys.each do |id|
        begin
          @connection.delete("host?ipid=#{id}")
        rescue => e
          # Not Found is ok, otherwise re-raise
          raise unless e.message =~ /404/
        end
      end
    end
  end
end
