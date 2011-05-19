module Spec  
  module Runner
    module Formatter
      class TerminalFormatter
        
        attr_reader :example_group, :example_group_number
        
        def initialize(options)
          @options = options
          @example_group_number = 0
          @example_number = 0
        end
        
        def start(number_of_examples)
          
        end
        
        def end
          
        end
        
        def example_group_started(example_group)
          @example_group = example_group
        end
        
        def example_started(example)
          @example_number += 1
        end
        
        def example_failed(example, counter, failure)
          puts "\033[0;31m#{@example_group.description}: #{example.description}\033[m"
          puts ""
          puts "  #{failure.exception.message}"
          puts ""
        end
        
        def example_passed(example)
          puts "\033[0;32m#{@example_group.description}: #{example.description}\033[m"
        end
        
        def example_pending(example, message)
          puts "\033[0;33m#{@example_group.description}: #{example.description}\033[m"
        end
        
      end
    end
  end
end
