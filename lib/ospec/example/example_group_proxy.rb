
module Spec
  module Example
    class ExampleGroupProxy

      attr_reader :description, :examples

      def initialize(example_group)
        @description = example_group.description
        @examples = example_group.example_proxies
      end
    end
  end
end

