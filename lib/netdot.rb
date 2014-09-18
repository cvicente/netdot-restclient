require 'logger'

module Netdot

  class << self
    attr_accessor :logger
  end

  class NullLogger < Logger
    def initialize(*args)
    end

    def add(*args, &block)
    end
  end

  Netdot.logger = NullLogger.new
end

require 'netdot/restclient'
require 'netdot/host'
require 'netdot/subnet'
