module Netdot
  class Subnet
    attr_accessor :connection

    def initialize(argv = {})
      [:connection].each do |k|
        raise ArgumentError, "Missing required argument '#{k}'" unless argv[k]
      end

      argv.each { |k,v| instance_variable_set("@#{k}", v) }
    end

    # Get next available subnet in given container
    #
    # Arguments:
    #    IP container block (string)
    #    CIDR subnet size (optional integer)
    #    description (optional string)
    # Returns:
    #    New subnet ID when successful
    #
    def allocate(container, prefix=24, description=nil)

      # Search for container and get its ID
      cont_id = get_ipblock_id(container)

      # Get container's children blocks
      begin
        resp = @connection.get("Ipblock?parent=#{cont_id}")
      rescue Exception => e
        # Not Found is ok, otherwise re-raise
        raise unless (e.message =~ /404/)
      end

      # store existing subnets in hash (if any)
      subnets = Hash.new
      if ( resp )
        resp.values.each do |b|
          b.each do |k,v|
            address = v['address']
            subnets[address] = 1
          end
        end
      end

      # Iterate over all possible subnets
      # This assumes that subnets are /24
      spref = container.split('/')[0]
      spref.gsub!(/(\d+\.\d+)\..*/, '\1')

      (1..255).each do |n|
        saddr = spref.dup
        saddr = spref + ".#{n}.0"
        if !subnets.empty? && subnets.key?(saddr)
          next # subnet exists
        end

        # Create subnet
        args = { 'address' => saddr, 'prefix' => prefix.to_s, 'status' => 'Subnet' }
        args['description'] = description unless description.nil?
        resp = @connection.post("Ipblock", args)
        return resp['address'] + '/' + resp['prefix']
      end

      raise "Could not allocate subnet in #{container}"
    end

    ######################################################################
    # Allocate range of addresses
    #
    # Allocates the first N available IPs in the given subnet
    # and creates A and PTR records, assuming that the subnet
    # is associated with the appropriate forward and reverse zones
    #
    # Arguments:
    #    subnet address
    #    subdomain
    #    number of adresses to allocate
    # Returns:
    #    Array of host names
    #
    def allocate_range(subnet, subdomain, num)
      names = []

      num.to_i.times do |i|
        n = i+1
        name = "vm-#{n}.#{subdomain}"
        # Make sure none of the names are already used
        begin
          resp = @connection.get("host?name=#{name}")
        rescue Exception => e
          # Not Found is expected
          raise unless (e.message =~ /404/)
          names.push name
        else
          raise "Name #{name} already exists!"
        end
      end

      names.each do |n|
        @connection.post('host', {'name' => n, 'subnet' => subnet})
      end

      return names
    end

    ######################################################################
    # Delete subnet and all its records
    #
    # Arguments:
    #    subnet address (CIDR)
    # Returns:
    #    True if successful
    #
    def delete(subnet)
      resp = @connection.get("host?subnet=#{subnet}")

      if ! resp.empty?
        resp['Ipblock'].keys.each do |id|
          @connection.delete("Ipblock/#{id}")
        end
      end

      sid = get_ipblock_id(subnet)
      @connection.delete("Ipblock/#{sid}")
    end

    private
    ######################################################################
    # Get Ipblock ID given its address in CIDR format
    #
    # Arguments:
    #    subnet address (CIDR)
    # Returns:
    #    ID (number)
    #
    def get_ipblock_id(cidr)
      (address, prefix) = cidr.split('/')
      resp = @connection.get("Ipblock?address=#{address}&prefix=#{prefix}")
      resp['Ipblock'].keys[0]
    end
  end
end
