require 'opal'
require 'opal/erb'
require 'opal/sprockets/processor'
require 'sprockets'

module Opal
  module ERB
    class Processor < ::Opal::Processor
      def evaluate(context, locals, &block)
        context.require_asset 'erb'
        Opal::ERB.compile data, context.logical_path.sub(/^templates\//, '')
      end
    end
  end
end

Tilt.register 'opalerb',               Opal::ERB::Processor
Sprockets.register_engine '.opalerb',  Opal::ERB::Processor
