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

      def indent(&block)
        @parser.indent(&block)
      end

      def current_indent
        @parser.parser_indent
      end

      def line(*strs)
        push "\n#{current_indent}"
        push(*strs)
      end

      def empty_line
        push "\n"
      end
    end
  end
end
