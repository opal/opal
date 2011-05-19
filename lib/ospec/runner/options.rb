module Spec
  module Runner
    class Options

      attr_accessor :reporter, :example_groups
      attr_writer :reporter

      def initialize
        @example_groups = []
        @reporter = Reporter.new self
      end

      def run_examples
        runner = ExampleGroupRunner.new self
        runner.run
      end

      def formatters
        return @formatters if @formatters
        if RUBY_ENGINE == "opal-browser"
          @formatters ||= [Spec::Runner::Formatter::HtmlFormatter.new(self)]
        else
          @formatters ||= [Spec::Runner::Formatter::TerminalFormatter.new(self)]
        end
      end

      def add_example_group(example_group)
        @example_groups << example_group
      end

    end # Options
  end
end

