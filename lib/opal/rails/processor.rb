require 'sprockets'

module Opal
  module Rails
    # Opal template implementation. See:
    # http://opalrb.org/
    #
    # Opal templates do not support object scopes, locals, or yield.
    class Processor < Tilt::Template
      self.default_mime_type = 'application/javascript'

      def self.engine_initialized?
        defined? ::Opal
      end

      def initialize_engine
        require_template_library 'opal'
      end

      def prepare
      end

      def evaluate(scope, locals, &block)
        Opal.parse(data)
      end
    end
  end
end

Tilt.register              'opal', Opal::Rails::Processor
Sprockets.register_engine '.opal', Opal::Rails::Processor

Tilt.register              'rb', Opal::Rails::Processor
Sprockets.register_engine '.rb', Opal::Rails::Processor
