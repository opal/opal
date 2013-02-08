require 'opal'
require 'sprockets'

module Opal
  class Processor < Tilt::Template
    self.default_mime_type = 'application/javascript'

    def self.engine_initialized?
      true
    end

    def initialize_engine
      require_template_library 'opal'
    end

    def prepare
      # ...
    end

    def evaluate(context, locals, &block)
      parser = Opal::Parser.new
      result = parser.parse data

      parser.requires.each { |r| context.require_asset r }
      result
    end
  end
end

Tilt.register 'rb',               Opal::Processor
Sprockets.register_engine '.rb',  Opal::Processor

Tilt.register 'opal',               Opal::Processor
Sprockets.register_engine '.opal',  Opal::Processor
