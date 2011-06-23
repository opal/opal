module Spec

  module DSL

    module Main

      def describe(name, &block)
        Spec::Example::ExampleGroupFactory.create_example_group name, &block
      end
    end # Main
  end
end

include Spec::DSL::Main

