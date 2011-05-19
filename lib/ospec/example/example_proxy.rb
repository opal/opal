module Spec
  module Example
    class ExampleProxy

      attr_reader :description

      def initialize(description, options = nil, location = nil)
        @description = description
      end

      def update(description)
        @description = description
        self
      end
    end # ExampleProxy
  end
end

