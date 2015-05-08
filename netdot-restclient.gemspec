# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'netdot/restclient/version'

Gem::Specification.new do |spec|
  spec.name          = 'netdot-restclient'
  spec.version       = Netdot::RestClient::VERSION
  spec.authors       = ['Carlos Vicente']
  spec.email         = ['cvicente@gmail.com']
  spec.summary       = 'RESTful API client for Netdot'
  spec.description   = 'Talk to Netdot via REST with Ruby'
  spec.homepage      = ''
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 2.6'

  spec.add_dependency 'httpclient'
  spec.add_dependency 'xml-simple'
end
