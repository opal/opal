module Spec  
  module Runner
    class ExampleGroupRunner
      
      def initialize(options)
        @options = options
      end
      
      def run
        prepare
        # puts "RUNNING"
        #`console.log(#{example_groups})`
        example_groups.each do |group|
          # puts "running group!"
          #puts group
          group.run @options
        end
        finish
      end
      
      def example_groups
        @options.example_groups
      end
      
      def prepare
        rep = reporter
        rep.start number_of_examples
      end
      
      def finish

      end
      
      def reporter
        @options.reporter
      end
      
      def number_of_examples
        0
      end
      
    end # ExampleGroupRunner
  end
end
