require 'ospec/matchers/operator_matcher'
require 'ospec/matchers/be'
require 'ospec/matchers/generated_descriptions'
require 'ospec/matchers/raise_error'

module Spec
  
  module Matchers
    
    class Matcher
      include Spec::Matchers
      
      # attr_reader :expected, :actual
      
      def initialize(name, expected, &declarations)
        @name = name
        @expected = expected
        instance_exec expected, &declarations
      end
      
    end # Matcher
  end # Matchers
end # Spec

