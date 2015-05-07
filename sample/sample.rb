#
# Example: Create, find, and delete Host and Ipblock resources.
#
require 'netdot'
require 'netaddr'

# Connect
netdot_restclient = Netdot::RestClient.new(server: 'http://ipam0-01-unicorn-usnbn1.ci-aws.dev.ec2.dynback.net/netdot',
                                           username: 'shortness',
                                           password: 'dyndns')

# Create a Netdot::Host object
netdot_host = Netdot::Host.new(connection: netdot_restclient)

# Create a Netdot::Ipblock object
netdot_ipblock = Netdot::Ipblock.new(connection: netdot_restclient)

# Ask Netdot to allocate a new CIDR block
cidr = netdot_ipblock.allocate('10.0.0.0/24', 24, 'example-net')

# Use NetAddr gem to allocate an address in the CIDR block
netaddr_cidr = NetAddr::CIDR.create(cidr)

# Use the first address
address = netaddr_cidr.nth(1)

# Create a new host (DNS A record)
netdot_host.create('example-host', address)

# Find the new host
_found = netdot_host.find_by_name('example-host')

# Delete the new Host
netdot_host.delete('example-host')

# Delete the new Ipblock, and all its children
ipblocks = netdot_ipblock.find_by_descr('example-net')
ipblocks.each do |ipblock|
  address = ipblock[1]['address']
  netdot_ipblock.delete(address, true)
end unless ipblocks.nil?

0
