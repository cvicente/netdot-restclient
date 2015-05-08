require 'logger'

# Netdot
module Netdot
  class << self
    attr_accessor :logger
  end

  # NullLogger
  class NullLogger < Logger
    def initialize(*_args)
    end

    def add(*_args, &_block)
    end
  end

  Netdot.logger = NullLogger.new
end

require 'netdot/restclient'
require 'netdot/host'
require 'netdot/ipblock'
