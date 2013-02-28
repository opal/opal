require 'opal'
require 'sprockets'

module Opal
  class Processor < Tilt::Template
    self.default_mime_type = 'application/javascript'

    def self.engine_initialized?
      true
    end

    class << self
      attr_accessor :method_missing_enabled
      attr_accessor :optimized_operators_enabled
      attr_accessor :arity_check_enabled
    end

    self.method_missing_enabled = true
    self.optimized_operators_enabled = true
    self.arity_check_enabled = false

    def initialize_engine
      require_template_library 'opal'
    end

    def prepare
    end

    def evaluate(context, locals, &block)
      options = { :method_missing       => self.class.method_missing_enabled,
                  :optimized_operators  => self.class.optimized_operators_enabled,
                  :arity_check          => self.class.arity_check_enabled,
                  :file                 => context.logical_path }

      parser  = Opal::Parser.new 
      result  = parser.parse data, options

      parser.requires.each { |r| context.require_asset r }
      result
    end
  end
end

Tilt.register 'rb',               Opal::Processor
Sprockets.register_engine '.rb',  Opal::Processor

Tilt.register 'opal',               Opal::Processor
Sprockets.register_engine '.opal',  Opal::Processor
