module Spec

  module DSL

    module Main

      def describe(name, &block)
        puts "Factory is:"
        puts Spec::Example::ExampleGroupFactory
        `console.log(#{Spec::Example::ExampleGroupFactory}.m$create_example_group);`
        Spec::Example::ExampleGroupFactory.create_example_group name, &block
      end
    end # Main
  end
end

include Spec::DSL::Main

