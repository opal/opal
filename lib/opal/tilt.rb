begin
  require 'tilt'

  module Tilt
    class OpalTemplate < Template
      def prepare
        @engine = Opal::Parser.new
        @output = nil
      end

      def evaluate(scope, locals, &block)
        @output ||= @engine.parse(data, options)
      end
    end
  end

  Tilt.register Tilt::OpalTemplate, 'opal'

rescue LoadError
  # Tilt is not available.
end
