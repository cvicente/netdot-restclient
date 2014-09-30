require 'spec_helper'

describe Netdot::RestClient do

  before :all do
    @netdot = connect
  end

  context 'when connecting' do

    it 'raises an exception for incomplete arguments' do
      args = {
        username:  'admin',
        server:    'http://localhost/netdot'
      }
      expect {
        Netdot::RestClient.new(args)
      }.to raise_error(ArgumentError)
    end

    it 'raises an exception for an invalid password' do
     args = {
        server:    ENV['SERVER'] || 'http://localhost/netdot',
        username:  ENV['USERNAME'] || 'admin',
        password:  'this-is-not-the-password'
      }
      expect {
        Netdot::RestClient.new(args)
      }.to raise_error
    end

    # The following two assume that local server has SSL
    # enabled with a self-signed cert
    it 'raises an exception if SSL verification fails' do
      args = {
        server:    ENV['SERVER'] || 'https://localhost/netdot',
        username:  ENV['USERNAME'] || 'admin',
        password:  ENV['PASSWORD'] || 'admin' 
      }
      expect {
        Netdot::RestClient.new(args)
      }.to raise_error
    end

    it 'does not raise an exception if SSL verification is disabled' do
      args = {
        server:     ENV['SERVER'] || 'https://localhost/netdot',
        username:   ENV['USERNAME'] || 'admin',
        password:   ENV['PASSWORD'] || 'admin', 
        ssl_verify: false
      }

      netdot = Netdot::RestClient.new(args)
      expect(netdot).to be_an_instance_of(Netdot::RestClient)
    end

    it 'connects to the API' do
      n = connect 
      expect(n).to be_an_instance_of(Netdot::RestClient)
    end

  end

  context 'when getting' do

    it 'invalid resource raises exception' do
      expect { 
        resp = @netdot.get('foobar')
      }.to raise_error
    end

    it 'valid resource as hash' do
      resp = @netdot.get('Entity/1')
      expect(resp).to be_an_instance_of(Hash)
    end
    
    it 'record by id' do
      resp = @netdot.get('Entity/1')
      expect(resp['name']).to eq('Unknown')
    end

    it 'records filtered by name' do
      resp = @netdot.get('Entity?name=Unknown')
      expect(resp['Entity']['1']['name']).to eq('Unknown')
    end

  end

  context 'when posting' do

    it 'fails to update invalid record' do
      expect {
        resp = @netdot.post('Foobar/1', {'key' => 'value'} )
      }.to raise_error
    end

    it 'creates new record' do
      resp = @netdot.post('Person', 
                          { 'firstname' => 'Joe', 
                            'lastname' => 'Plumber',
                            'username' => 'joetubes'
                          })
      expect(resp['firstname']).to eq ('Joe')
      expect(resp['lastname']).to eq ('Plumber')

    end

    it 'fails to create duplicate record' do
      expect {
        resp = @netdot.post('Person', 
                            { 'firstname' => 'Joe', 
                              'lastname' => 'Plumber',
                              'username' => 'joetubes'
                            })
      }.to raise_error
    end

  end

  context 'when deleting' do
    
    it 'fails to delete invalid record' do
      expect {
        resp = @netdot.delete('FooBar/1234')
      }.to raise_error
    end

    it 'deletes exiting record' do
      resp = @netdot.get('Person?lastname=Plumber')
      person_id =  resp['Person'].keys[0]
      resp = @netdot.delete("Person/#{person_id}")
      expect(resp).to be_truthy
    end

  end

end

