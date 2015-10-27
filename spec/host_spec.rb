require 'spec_helper'

describe Netdot::Host do
  before :all do
    @netdot = connect
    @ipblock = Netdot::Ipblock.new(connection: @netdot)
    @host = Netdot::Host.new(connection: @netdot) if @host.nil?
    @test_net = '198.18.254.0/24' # RFC 2544
    @test_6net = '2001:db8:ffff::/64' # RFC 3839
    @netdot.post('Ipblock', 'address' => @test_net, 'status' => 'Subnet')
    @netdot.post('Ipblock', 'address' => @test_6net, 'status' => 'Subnet')
    @cidr = NetAddr::CIDR.create(@test_net)
    @cidr6 = NetAddr::CIDR.create(@test_6net)
  end

  context 'when creating a new Host instance' do
    it 'creates a new instance' do
      expect do
        Netdot::Host.new(connection: @netdot)
      end.not_to raise_error
    end

    it 'raises an exception for invalid arguments' do
      expect do
        Netdot::Host.new
      end.to raise_error(ArgumentError)
    end
  end

  context 'when creating a new host' do
    it 'creates new records for given name and IP' do
      h = @host.create('rspec-test0-01-yyy', @cidr.nth(1))
      expect(h.key? 'name').to be_truthy
      expect(h['name']).to match('rspec-test0-01-yyy')
    end

    it 'creates new records for given name in given v4 subnet' do
      h = @host.create_next('rspec-test0-02-yyy', @cidr.to_s)
      expect(h).to be_truthy
      expect(h).to match(@cidr.nth(2))
    end

    it 'creates new records for given name in given v6 subnet' do
      h = @host.create_next('rspec-test0-02-yyy', @cidr6.to_s(Short: true))
      expect(h).to be_truthy
      expect(h).to match(@cidr6.nth(1, Short: true))
    end

    it 'updates an existing allocation' do
      h = @host.update('rspec-test0-01-zzz', @cidr.nth(1))
      expect(h.key? 'name').to be_truthy
      expect(h['name']).to match('rspec-test0-01-zzz')
    end
  end

  context 'when finding existing hosts' do
    it 'finds a host by name' do
      h = @host.find_by_name('rspec-test0-01-zzz')
      expect(h).to be_instance_of(Hash)
    end

    it 'finds a host by ip' do
      h = @host.find_by_ip(@cidr.nth(1))
      expect(h).to be_instance_of(Hash)
    end
  end

  context 'when deleting a host' do
    it 'deletes a host' do
      expect do
        @host.delete('rspec-test-01-zzz')
      end.not_to raise_error
    end
  end

  context 'when cleaning up' do
    it 'deletes test subnet and all its children' do
      expect(@ipblock.delete(@test_net, true)).to be_truthy
    end
    it 'deletes test v6 subnet and all its children' do
      expect(@ipblock.delete(@test_6net, true)).to be_truthy
    end
  end
end
