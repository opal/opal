require 'opal/parser'

module Opal
  module ERB
    def self.parse(source, file_name = '(erb)')
      Compiler.new.compile source, file_name
    end

    class Compiler
      def compile(source, file_name = '(erb)')
        @source, @file_name, @result = source, file_name, source

        self.fix_quotes
        self.find_contents
        self.find_code
        self.wrap_compiled

        Opal.parse @result
      end

      def fix_quotes
        @result = @result.gsub '"', '\\"'
      end

      def find_contents
        @result = @result.gsub(/<%=([\s\S]+?)%>/) do
          inner = $1.gsub(/\\'/, "'").gsub(/\\"/, '"')
          "\")\nout.<<(#{ inner })\nout.<<(\""
        end
      end

      def find_code
        @result = @result.gsub(/<%([\s\S]+?)%>/) do
          "\")\n#{ $1 }\nout.<<(\""
        end
      end

      def wrap_compiled
        @result = "ERB.new('#@file_name') do |out|\nout.<<(\"#@result\")\nout.join\nend\n"
      end
    end
  end
end
