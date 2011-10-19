require 'ruby_parser'

require 'opal/parser/processor'
require 'opal/parser/scope'

module Opal

  class Parser
    def parse(source, options = {})
      @options = options
      @file    = "__OPAL_LIB_FILE_STRING"

      begin
        parser = RubyParser.new
        process parser.parse(source, @file)
      rescue => e
        raise e.message + " (on line #{parser.lexer.lineno})\n#{parser.lexer.src.peek 100}"
      end
    end

    def process(sexp, options = {})
      (@processor ||= Processor.new(@file)).top(sexp, @options.merge(options))
    end
  end
end

