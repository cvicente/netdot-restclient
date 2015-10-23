require 'spec_helper'

describe Netdot::Ipblock do
  before :all do
    @netdot = connect
    @ipblock = Netdot::Ipblock.new(connection: @netdot) if @ipblock.nil?
    @host = Netdot::Host.new(connection: @netdot) if @host.nil?
  end

  context 'when creating a new Ipblock instance' do
    it 'creates a new instance' do
      expect do
        Ipblock = Netdot::Ipblock.new(connection: @netdot)
      end.not_to raise_error
    end

    it 'raises an exception for invalid arguments' do
      expect do
        Ipblock = Netdot::Ipblock.new
      end.to raise_error(ArgumentError)
    end
  end

  context 'when creating a new Ipblock' do
    it 'allocates a new Ipblock' do
      cidr = @ipblock.allocate('10.0.0.0/8', 24, 'rspec-Ipblock-one')
      expect(cidr).to match('10.0.*.0/24')
    end

    it 'raises an exception if the prefix is not /24' do
      expect do
        @ipblock.allocate('10.0.0.0/8', 26)
      end.to raise_error(ArgumentError)
    end
  end

  context 'when finding an Ipblock by description' do
    it 'finds an Ipblock' do
      expect(@ipblock.find_by_descr('rspec-Ipblock-one')).not_to be_nil
    end

    it 'raises an exception for an improperly formatted name' do
      expect do
        @ipblock.find_by_descr('rspec-Ipblock-one&Foo=bar')
      end.to raise_error
    end

    it 'return nil for a non-existent string' do
      expect(@ipblock.find_by_descr('21684dfgergscvfwr')).to be_nil
    end

    it 'return nil if not found' do
      expect(@ipblock.find_by_descr('rspec-Ipblock-bogus')).to be_nil
    end
  end

  context 'when finding an Ipblock by CIDR' do
    it 'finds an Ipblock' do
      cidr = @ipblock.allocate('10.0.0.0/8', 24, 'rspec-Ipblock-two')
      ipblock = @ipblock.find_by_addr(cidr)
      expect(ipblock).not_to be_nil
    end

    it 'return nil if not found' do
      expect(@ipblock.find_by_addr('1.2.3.4/32')).to be_nil
    end
  end

  context 'when finding an Ipblock by address' do
    it 'finds an Ipblock' do
      cidr = @ipblock.allocate('10.0.0.0/8', 24, 'rspec-Ipblock-three')
      (address, _prefix) = cidr.split('/')
      ipblock = @ipblock.find_by_addr(address)
      expect(ipblock).not_to be_nil
    end

    it 'return nil if not found' do
      expect(@ipblock.find_by_addr('1.2.3.4')).to be_nil
    end
  end

  context 'when deleting an Ipblock' do
    it 'deletes an Ipblock' do
      cidr = @ipblock.allocate('10.0.0.0/8', 24, 'rspec-Ipblock-four')
      expect(@ipblock.delete(cidr)).to be_truthy
    end

    it 'deletes an Ipblock, and its children' do
      cidr = @ipblock.allocate('10.0.0.0/8', 24, 'rspec-Ipblock-five')
      netaddr_cidr = NetAddr::CIDR.create(cidr)
      @host.create('rspec-test0-01-yyy', netaddr_cidr.nth(1))
      expect(@ipblock.delete(cidr, true)).to be_truthy
    end
  end

  context 'when cleaning up' do
    %w( host one two three four five ).each do |s|
      description = format('rspec-Ipblock-%s', s)
      it "finds and deletes Ipblock '#{description}'" do
        ipblocks = @ipblock.find_by_descr(description)
        ipblocks.each do |ipblock|
          address = ipblock[1]['address']
          @ipblock.delete(address, true)
        end unless ipblocks.nil?
      end
    end
  end
end
