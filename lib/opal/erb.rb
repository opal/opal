require 'opal/compiler'

module Opal
  module ERB
    # Compile ERB code into javascript.
    #
    # [Opal::ERB] can be used to compile [ERB] templates into javascript code.
    # This module uses the [Opal::Compiler] internally.
    #
    # Compiled templates, when run in a javascript environment, will appear
    # under the `Template` namespace, and can be accessed as:
    #
    #     Template['template_name'] # => template instance
    #
    # @example
    #
    #     source = "<div><%= @content %></div>"
    #
    #     Opal::ERB.compile source, "my_template.erb"
    #
    # @param source [String] erb content
    # @param file_name [String] filename for reference in template
    # @return [String] javascript code
    #
    def self.compile(source, file_name = '(erb)')
      Compiler.new(source, file_name).compile
    end

    class Compiler
      BLOCK_EXPR = /\s+(do|\{)(\s*\|[^|]*\|)?\s*\Z/

      def initialize(source, file_name = '(erb)')
        @source, @file_name, @result = source, file_name, source
      end

      def prepared_source
        @prepared_source ||= begin
          source = @source
          source = fix_quotes(source)
          source = find_contents(source)
          source = find_code(source)
          source = wrap_compiled(source)
          source = require_erb(source)
          source
        end
      end

      def compile
        Opal.compile prepared_source
      end

      def fix_quotes(result)
        result.gsub '"', '\\"'
      end

      def require_erb(result)
        'require "erb";'+result
      end

      def find_contents(result)
        result.gsub(/<%=([\s\S]+?)%>/) do
          inner = $1.gsub(/\\'/, "'").gsub(/\\"/, '"')

          if inner =~ BLOCK_EXPR
            "\")\noutput_buffer.append= #{ inner }\noutput_buffer.append(\""
          else
            "\")\noutput_buffer.append=(#{ inner })\noutput_buffer.append(\""
          end
        end
      end

      def find_code(result)
        result.gsub(/<%([\s\S]+?)%>/) do
          "\")\n#{ $1 }\noutput_buffer.append(\""
        end
      end

      def wrap_compiled(result)
        path = @file_name.sub(/\.opalerb$/, '')
        result = "Template.new('#{path}') do |output_buffer|\noutput_buffer.append(\"#{result}\")\noutput_buffer.join\nend\n"
      end
    end
  end
end
