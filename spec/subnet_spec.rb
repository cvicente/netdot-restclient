require 'spec_helper'

describe Netdot::Subnet do

  before :all do
    @netdot = connect
    @subnet = Netdot::Subnet.new(:connection => @netdot) if @subnet.nil?
  end

  context 'when creating a new Subnet instance' do
    it 'creates a new instance' do
      expect {
        subnet = Netdot::Subnet.new(:connection => @netdot)
      }.not_to raise_error
    end

    it 'raises an exception for invalid arguments' do
      expect {
        subnet = Netdot::Subnet.new
      }.to raise_error(ArgumentError)
    end
  end

  context 'creating a new subnet' do
    it 'allocates a new subnet' do
      subnet_id = @subnet.allocate('10.0.0.0/8', 24, 'test')
      expect(subnet_id).to match('10.0.*.0/24') 
    end

    it 'throws an exception if the prefix is not /24' do
      expect {
        subnet_id = @subnet.allocate('10.0.0.0/8', 26)
      }.to raise_error(ArgumentError)
    end
  end

  context 'deleting a subnet' do
    let(:subnet_id) do
      @subnet.allocate('10.0.0.0/8', 24)
    end

    it 'deletes a subnet' do
      expect(@subnet.delete(subnet_id)).to be_truthy
    end
  end
end
