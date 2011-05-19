module Spec

  module Example

    class ExamplePendingError < StandardError

    end

    class NotYetImplementedError < ExamplePendingError

      def initialize
        @message = "Not Yet Implemented"
      end
    end
  end
end

