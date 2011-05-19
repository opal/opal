module Spec
  module Runner
    class Reporter

      attr_reader :options

      def initialize(options)
        @options = options
        @options.reporter = self
        @failures = []
        @pending_count = 0
        @example_count = 0
      end

      def start(number_of_examples)
        @start_time = 0
        formatters.each do |f|
          f.start number_of_examples
        end
      end

      def formatters
        @options.formatters
      end

      def example_group_started(example_group)
        @example_group = example_group
        formatters.each do |f|
          f.example_group_started example_group
        end
      end

      def example_started(example)
        formatters.each do |f|
          f.example_started example
        end
      end

      def example_finished(example, error)
        if error.nil?
          example_passed example
        elsif Spec::Example::ExamplePendingError === error
          example_pending example, error.message
        else
          example_failed example, error
        end
      end

      def example_failed(example, error)
        failure = Failure.new @example_group.description, example.description, error
        @failures << failure
        formatters.each do |f|
          f.example_failed example, @failures.length, failure
        end
      end

      def example_passed(example)
        formatters.each do |f|
          f.example_passed example
        end
      end

      def example_pending(example, message)
        # @pending_count += 1
        formatters.each do |f|
          f.example_pending example, message
        end
      end
    end # Reporter

    class Failure

      attr_reader :exception

      def initialize(group_description, example_description, exception)
        @example_name = "#{group_description} #{example_description}"
        @exception = exception
      end
    end
  end
end

