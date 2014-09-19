require 'netdot'
require 'netaddr'

@netdot = nil

def connect
  args = {
    server:     ENV['SERVER'] || 'http://localhost/netdot',
    username:   ENV['USERNAME'] || 'admin',
    password:   ENV['PASSWORD'] || 'admin',
    ssl_verify: false
  }
  @netdot = Netdot::RestClient.new(args) if @netdot.nil?
  return @netdot
end
