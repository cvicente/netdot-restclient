# Netdot
module Netdot
  # Manage Ipblock objects.
  class Ipblock
    attr_accessor :connection

    # Constructor
    # @param :connection [Hash] a Netdot::RestClient object
    def initialize(argv = {})
      [:connection].each do |k|
        fail ArgumentError, "Missing required argument '#{k}'" unless argv[k]
      end

      argv.each { |k, v| instance_variable_set("@#{k}", v) }
    end

    # Gets the next available Ipblock in the specified container.
    # @param container [String] address
    # @param prefix [Fixnum]
    # @param description [String] (optional)
    # @return [String] new Ipblock id, or nil
    def allocate(container, prefix = 24, description = nil)
      # Netdot currently only supports /24 prefixes
      fail ArgumentError,
           "Prefix size #{prefix} is not currently supported (must be 24)" \
        unless prefix == 24

      # Search for container and get its ID
      cont_id = find_by_addr(container)

      # Get container's children blocks
      begin
        resp = @connection.get("Ipblock?parent=#{cont_id}")
      rescue => e
        # Not Found is ok, otherwise re-raise
        raise unless e.message =~ /404/
      end

      # store existing Ipblocks in hash (if any)
      ipblocks = {}
      if resp
        resp.values.each do |b|
          b.each do |_k, v|
            address = v['address']
            ipblocks[address] = 1
          end
        end
      end

      # Iterate over all possible Ipblocks
      # This assumes that Ipblocks are /24
      spref = container.split('/')[0]
      spref.gsub!(/(\d+\.\d+)\..*/, '\1')

      (1..255).each do |n|
        spref.dup
        saddr = spref + ".#{n}.0"
        if !ipblocks.empty? && ipblocks.key?(saddr)
          next # Ipblock exists
        end

        # Create Ipblock
        args = {
          'address' => saddr,
          'prefix' => prefix.to_s,
          'status' => 'Subnet'
        }
        args['description'] = description unless description.nil?
        resp = @connection.post('Ipblock', args)
        return resp['address'] + '/' + resp['prefix']
      end

      fail "Could not allocate Ipblock in #{container}"
    end

    # Deletes an Ipblock (and optionally, all its children), for the specified
    # address or CIDR.
    # @param ipblock [String] address or CIDR
    # @return (Truth)
    def delete(ipblock, recursive = false)
      if recursive
        resp = @connection.get("host?subnet=#{ipblock}")
        unless resp.empty?
          resp['Ipblock'].keys.each do |id|
            @connection.delete("Ipblock/#{id}")
          end
        end
      end

      sid = find_by_addr(ipblock)
      @connection.delete("Ipblock/#{sid}")
    end

    # Gets the matching Ipblock id for the specified address (in CIDR format).
    # @param cidr [String]
    # @return [Ipblock]
    def find_by_addr(cidr)
      (address, prefix) = cidr.split('/')
      prefix ||= '24'
      begin
        @connection.get("Ipblock?address=#{address}&prefix=#{prefix}")[
          'Ipblock'].keys[0]
      rescue => e
        raise unless e.message =~ /404/
      end
    end

    # Gets an array of matching Ipblock ids for the specified description
    # (name).
    # @param descr [String]
    # @return [Array<Ipblock>]
    def find_by_descr(descr)
      @connection.get("Ipblock?description=#{descr}")['Ipblock']
      rescue => e
        raise unless e.message =~ /404/
    end
  end
end
