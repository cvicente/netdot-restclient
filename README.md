# Netdot::RestClient

RESTful API Ruby client for the Network Documentation Tool

## Installation

Add this line to your application's Gemfile:

    gem 'netdot-restclient'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install netdot-restclient

## Usage

	require 'netdot/restclient'
	require 'pp'

	netdot = Netdot::RestClient.new(
        :server   => 'http://localhost.localdomain/netdot',
        :username => 'admin',
        :password => 'xxxxx',
    )

    # Get all devices
    devs = netdot.get('/Device');

    pp devs

    # Get Device id 1
    dev = netdot.get('/Device/1');

    # Get Device id 1 and foreign objects one level away
    dev = netdot.get('/Device/1?depth=1');

    # Update Device 1
    dev = netdot.post('/Device/1', {community=>'public'});

    # Delete Device 1
    netdot.delete('/Device/1');

## See Also

The Netdot user manual at:

    http://netdot.uoregon.edu

## Contributing

1. Fork it ( https://github.com/cvicente/netdot-restclient/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
