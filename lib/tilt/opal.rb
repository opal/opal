require 'tilt'
require 'opal/compiler'
require 'opal/config'
require 'opal/version'

$OPAL_SOURCE_MAPS = {}

module Opal
  class TiltTemplate < Tilt::Template
    self.default_mime_type = 'application/javascript'

    def self.engine_initialized?
      true
    end

    def self.version
      ::Opal::VERSION
    end

    def self.compiler_options
      Opal::Config.compiler_options.merge(requirable: true)
    end

    def initialize_engine
      require_template_library 'opal'
    end

    def prepare
    end

    def evaluate(context, locals, &block)
      compiler_options = Opal::Config.compiler_options.merge(file: file)
      compiler = Compiler.new(data, compiler_options)
      compiler.compile.to_s
    end

    def compiler_options
      self.class.compiler_options
    end
  end
end

Tilt.register 'rb',   Opal::TiltTemplate
Tilt.register 'opal', Opal::TiltTemplate
