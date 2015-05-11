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

See the sample/sample.rb for sample usage of the Host and Ipblock classes.

## Contributing

1. Fork it ( https://github.com/cvicente/netdot-restclient/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### Setting up a development environment on Ubuntu 14.04
* Resynchronize the package index files from their sources.
```
sudo apt-get update
```
* Install rbenv, then reconfigure PATH.
```
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
cat >>~/.bashrc <<EOF
export PATH=~/.rbenv/bin:\$PATH
eval "\$(rbenv init -)"
EOF
```
* Logout and back in!
```
logout
```
* Install and verify the desired Ruby version.
```
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
rbenv install 1.9.3-p547
cat >~/.rbenv/version <<EOF
1.9.3-p547
EOF
rbenv rehash
ruby --version
```
* Install the bundler gem
```
rbenv exec gem install bundler
rbenv rehash
bundle version
```
* Install the netdot-restclient code
```
git clone https://github.com/cvicente/netdot-restclient.git
cd netdot-restclient
```
* Run the bundler, to ensure we have all the gems we need
```
bundle install
```
* Optional: set environment variables for rspec tests
```
export SERVER=http://ipam0-01-unicorn-usnbn1.ci-aws.dev.ec2.dynback.net/netdot
```
* Run the default rake tasks
```
rake
```
