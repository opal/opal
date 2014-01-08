require 'opal'
require 'opal/compiler'
require 'sprockets'

module Opal
  module ERB
    class Processor < Tilt::Template
      self.default_mime_type = 'application/javascript'

      def self.engine_initialized?
        true
      end

      def initialize_engine
        require_template_library 'opal'
      end

      def prepare
      end

      def evaluate(context, locals, &block)
        context.require_asset 'erb'
        Opal::ERB.compile data, context.logical_path.sub(/^templates\//, '')
      end
    end
  end
end

Tilt.register 'opalerb',               Opal::ERB::Processor
Sprockets.register_engine '.opalerb',  Opal::ERB::Processor
