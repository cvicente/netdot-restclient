require 'spec_helper'

describe Netdot::Host do

  before :all do
    @netdot = connect
    @host = Netdot::Host.new(:connection => @netdot) if @host.nil?
    subnet = Netdot::Subnet.new(:connection => @netdot)
    subnet_id = subnet.allocate('10.0.0.0/8', 26, 'test')
    @cidr = NetAddr::CIDR.create(subnet_id)
  end

  context 'when creating a new Host instance' do
    it 'creates a new instance' do
      expect {
        host = Netdot::Host.new(:connection => @netdot)
      }.not_to raise_error
    end

    it 'raises an exception for invalid arguments' do
      expect {
        host = Netdot::Host.new
      }.to raise_error(ArgumentError)
    end
  end

  context 'creating a new host' do
    it 'creates a new host allocation' do
      h = @host.create('test0-01-yyy', @cidr.nth(1))
      expect(h.key? 'name').to be_truthy
      expect(h['name']).to match('test0-01-yyy')
    end

    it 'updates an existing allocation' do
      h = @host.update('test0-01-zzz', @cidr.nth(1))
      expect(h.key? 'name').to be_truthy
      expect(h['name']).to match('test0-01-zzz')
    end
  end

  context 'finding existing hosts' do
    it 'finds a host by name' do
      h = @host.find_by_name('test0-01-zzz')
      expect(h).to be_instance_of(Hash)
    end

    it 'finds a host by ip' do
      h = @host.find_by_ip(@cidr.nth(1))
      expect(h).to be_instance_of(Hash)
    end
  end

  context 'deleting a host' do
    it 'deletes a host' do
      expect {
        @host.delete('test-01-zzz')
      }.not_to raise_error
    end
  end
end
