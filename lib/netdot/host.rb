module Netdot
  class Host
    attr_accessor :connection

    def initialize(argv = {})
      [:connection].each do |k|
        raise ArgumentError, "Missing required argument '#{k}'" unless argv[k]
      end

      argv.each { |k,v| instance_variable_set("@#{k}", v) }
    end

    ##############################################################
    # Find RR and Ipblock records with flexible arguments
    # Handle exceptions
    def find(param, value)
      begin
        host = @connection.get("/host?#{param.to_s}=#{value}");
      rescue Exception => e
        # Not Found is ok, otherwise re-raise
        raise unless (e.message =~ /404/)
      end
      # Return what we got
      host
    end

    ##############################################################
    # Find RR and Ipblock records associated with given name
    def find_by_name(name)
      find(:name, name)
    end

    ##############################################################
    # Find RR and Ipblock records associated with this IP
    def find_by_ip(ip)
      find(:address, ip)
    end

    ##############################################################
    # Create A record for given name and IP
    # Will also create PTR record if .arpa zone exists
    def create(name, ip)
      Netdot.logger.debug("Creating new DNS records with name:#{name} and ip:#{ip}")
      @connection.post('host', {'name' => name, 'address' => ip})
    end

    ##############################################################
    # Update A record for given name and IP
    # Will also create PTR record if .arpa zone exists
    def update(name, ip)
      Netdot.logger.debug("Updating DNS records with name:#{name} and ip:#{ip}")
      delete(name)
      #delete_by_ip(ip)
      create(name, ip)
    end

    ##############################################################
    # Delete A record for given name
    def delete(name)
      host = find_by_name(name)
      return unless host

      # remove any associated IP addresses
      Netdot.logger.debug("Removing IP records for #{name}")
      host['Ipblock'].keys.each do |id|
        begin
          @connection.delete("host?ipid=#{id}")
        rescue Exception => e
          # Not Found is ok, otherwise re-raise
          raise unless (e.message =~ /404/)
        end
      end
    end

  end
end
