require 'tilt'
require 'sprockets'

module Opal
  module ERB
    class Processor < Tilt::Template
      # vvv BOILERPLATE vvv
      self.default_mime_type = 'application/javascript'

      def self.engine_initialized?
        true
      end

      def self.version
        ::Opal::VERSION
      end

      def initialize_engine
        require_template_library 'opal'
        require_template_library 'opal/erb'
      end

      def prepare
      end
      # ^^^ BOILERPLATE ^^^


      def evaluate(context, locals, &block)
        context.require_asset 'erb'
        Opal::ERB.compile data, context.logical_path.sub(/^templates\//, '')
      end
    end
  end
end

Tilt.register 'opalerb',               Opal::ERB::Processor
Sprockets.register_engine '.opalerb',  Opal::ERB::Processor
