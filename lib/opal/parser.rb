require 'ruby_parser'

require 'opal/parser/processor'
require 'opal/parser/scope'

module Opal

  class Parser
    def parse(source, options = {})
      @options = options
      @file    = "__OPAL_LIB_FILE_STRING"

      process RubyParser.new.parse(source, @file)
    end

    def process(sexp, options = {})
      (@processor ||= Processor.new(@file)).top(sexp, @options.merge(options))
    end
  end
end

