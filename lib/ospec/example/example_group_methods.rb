module Spec
  module Example
    module ExampleGroupMethods

      include Spec::Example::BeforeAndAfterHooks

      def describe group_name, &group_block
        subclass group_name, &group_block
      end

      def subclass group_name, &group_block
        @class_count ||= 0
        klass = const_set "Subclass#{@class_count}", Class.new(self)
        klass.description = group_name
        Spec::Example::ExampleGroupFactory.register_example_group klass
        klass.module_eval(&group_block)
        klass
      end

      def example(example_name, &implementation)
        example_proxy = Spec::Example::ExampleProxy.new example_name
        example_proxies << example_proxy
        example_implementations[example_proxy] = implementation || pending_implementation
        example_proxy
      end

      alias_method :it, :example
      alias_method :specify, :example

      def description
        @description ||= "PLACEHOLDER DESCRIPTION"
      end

      def description=(description)
        @description = description
        self
      end

      def pending_implementation
        proc {
          raise Spec::Example::NotYetImplementedError.new
        }
      end

      def run(run_options)
        examples = examples_to_run run_options
        notify run_options.reporter
        success = true
        before_all_instance_variables = nil

        run_before_all run_options
        run_examples success, before_all_instance_variables, examples, run_options
        run_after_all run_options
      end

      def run_examples(success, instance_variables, examples, run_options)
        examples.each do |example|
          example_group_instance = new example,
                                       &example_implementations[example]

          example_group_instance.execute run_options, instance_variables
        end
      end

      def run_before_all(run_options)
        before_all_parts.each do |part|
          part.call
        end
      end

      def run_after_all(run_options)
        after_all_parts.each do |part|
          part.call
        end
      end

      def notify(reporter)
       reporter.example_group_started Spec::Example::ExampleGroupProxy.new(self)
      end

      def examples_to_run(run_options)
        example_proxies
      end

      def example_proxies
        @example_proxies ||= []
      end

      def example_implementations
        @example_implementations ||= {}
        @example_implementations
      end

      def example_group_hierarchy
        @example_group_hierarchy ||= Spec::Example::ExampleGroupHierarchy.new self
      end
    end
  end
end

