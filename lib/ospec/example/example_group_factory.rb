
module Spec

  module Example

    class ExampleGroupFactory

      def self.register_example_group klass
        Spec::Runner.options.add_example_group klass
      end

      def self.create_example_group(group_name, &block)
        puts "did we get ehre?"
        ExampleGroup.describe group_name, &block
      end
    end
  end
end

