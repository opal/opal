
module Spec
  
  module Example
    
    class ExampleGroupHierarchy
      
      def initialize(example_group_class)
        @example_group_class = example_group_class
      end
      
      def run_before_each(example)
        @example_group_class.before_each_parts.each do |part|
          # puts "in each part before"
          example.instance_eval &part
        end
      end
      
    end
  end
end
