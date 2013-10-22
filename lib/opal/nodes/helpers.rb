module Opal
  class Parser
    module NodeHelpers

      def property(name)
        reserved?(name) ? "['#{name}']" : ".#{name}"
      end

      def reserved?(name)
        Opal::Parser::RESERVED.include? name
      end

      def variable(name)
        reserved?(name) ? "#{name}$" : name
      end
    end
  end
end
