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

      # Netdot currently only supports /24 prefixes
      raise ArgumentError, "Prefix size #{prefix} is not currently supported (must be 24)" unless prefix==24

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
