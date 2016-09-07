require 'tilt'
require 'sprockets'
require 'opal/sprockets/processor'

module Opal
  module ERB
    class Transformer
      def self.call(input)
        data         = input[:data]
        logical_path = input[:name]
        compiler = ::Opal::ERB::Compiler.new(@data, logical_path.sub(/#{REGEXP_START}templates\//, ''))
        data = compiler.prepared_source
        ::Opal::Processor.call input.merge(data: data)
      end
    end

    class Processor < ::Opal::Processor
      def initialize_engine
        super
        require_template_library 'opal/erb'
      end

      def evaluate(context, locals, &block)
        compiler = Opal::ERB::Compiler.new(@data, context.logical_path.sub(/#{REGEXP_START}templates\//, ''))
        @data = compiler.prepared_source
        super
      end
    end
  end
end

Tilt.register 'opalerb', Opal::ERB::Processor

case
when Sprockets.respond_to?(:register_transformer)
  Sprockets.register_mime_type 'text/opal-embedded-ruby', extensions: %w[.opalerb .js.opalerb], charset: :unicode
  Sprockets.register_transformer 'text/opal-embedded-ruby', 'application/javascript', Opal::ERB::Transformer

when Sprockets.respond_to?(:register_engine)
  Sprockets.register_engine '.opalerb', Opal::ERB::Processor
end
