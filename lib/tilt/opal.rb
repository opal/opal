require 'tilt'
require 'opal/compiler'
require 'opal/version'

$OPAL_SOURCE_MAPS = {}

module Opal
  class Processor < Tilt::Template
    # vvv BOILERPLATE vvv
    self.default_mime_type = 'application/javascript'

    def self.inherited(subclass)
      subclass.default_mime_type = default_mime_type
    end

    def self.engine_initialized?
      true
    end

    def self.version
      ::Opal::VERSION
    end

    module InstanceMethods
      def initialize_engine
        require_template_library 'opal'
      end

      def prepare
      end

      def evaluate(context, locals, &block)
        Opal.compile data, file: file
      end
    end

    include InstanceMethods
  end
end

Tilt.register 'rb',   Opal::Processor
Tilt.register 'opal', Opal::Processor
