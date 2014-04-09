#
# Example: Use the special-purpose 'host' resource 
# to allocate a new IP and assign DNS records
#
#
require 'netdot/restclient'

require 'pp'

netdot = Netdot::RestClient.new(
                                :server   => 'http://localhost/netdot',
                                :username => 'admin',
                                :password => 'admin',
                                )
# Add 
# This allocates the first available IP in the given subnet
# and creates A and PTR records, assuming that the subnet
# is associated with the appropriate forward and reverse zones
netdot.post('host', { 'name' => 'testhost1', 'subnet' => '192.168.1.0/24'})

# Find
resp = netdot.get('host?name=testhost1.defaultdomain')

pp resp

ipid = resp['Ipblock'].keys[0]

# Delete DNS records associated with new IP
netdot.delete("host?ipid=#{ipid}")

# Notice that the above does not delete the Ipblock object, but
# marks it as "available"
# If user has admin privileges and really wants to delete the 
# Ipblock, then they can do:

netdot.delete("Ipblock/#{ipid}")
