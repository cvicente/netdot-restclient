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

  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'logger', '~>1.2'
  spec.add_development_dependency 'netaddr', '~>1.5'
  spec.add_development_dependency 'rake', '~>10.4'
  spec.add_development_dependency 'redcarpet', '~>3.2'
  spec.add_development_dependency 'rspec', '~> 2.99'
  spec.add_development_dependency 'rubocop', '~>0.31'
  spec.add_development_dependency 'yard', '~>0.8'

  spec.add_runtime_dependency 'httpclient', '~>2.6'
  spec.add_runtime_dependency 'xml-simple', '~>1.1'
end
