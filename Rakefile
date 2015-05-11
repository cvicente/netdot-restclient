#
# Rakefile
#

require 'rake'
require 'rake/clean'

CLEAN.include('.yardoc',
              'cookie.dat'
             )
CLOBBER.include('doc',
                'pkg'
               )

#---------------------------------------------------------------------------
# Packaging (bundler) -- build, install, and release

require 'bundler/gem_tasks'

#---------------------------------------------------------------------------
# Documentation (yard)

require 'yard'
YARD::Rake::YardocTask.new

desc 'Use yard for doc'
task doc: :yard

#---------------------------------------------------------------------------
# Test

require 'rspec/core/rake_task'

# These are for running 'rspec' with our Netdot test server
ENV['SERVER'] ||= 'http://localhost/netdot'
ENV['USERNAME'] ||= 'admin'
ENV['PASSWORD'] ||= 'admin'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**{,/*/**}/*_spec.rb'
  t.rspec_opts = '--format documentation'
end

desc 'Use rspec for test'
task test: :spec

#---------------------------------------------------------------------------
# Style (rubocop)

require 'rubocop/rake_task'
RuboCop::RakeTask.new

desc 'Use rubocop for style'
task style: :rubocop

#---------------------------------------------------------------------------

desc 'Build the Gem if style, test, and doc are successful'
task default: [:rubocop, :spec, :yard, :build]
