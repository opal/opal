# use_strict: true
# frozen_string_literal: true

require 'corelib/marshal/read_buffer'
require 'corelib/marshal/write_buffer'

module Marshal
  MAJOR_VERSION = 4
  MINOR_VERSION = 8

  class << self
    def dump(object)
      WriteBuffer.new(object).write
    end

    def load(marshaled)
      ReadBuffer.new(marshaled).read
    end

    alias restore load
  end
end
