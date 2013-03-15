require 'opal/lexer'
require 'opal/grammar'
require 'opal/target_scope'
require 'opal/code_generator'

module Opal
  class Parser
    def parse(source, options = {})
      @grammar = Grammar.new
      @sexp = @grammar.parse source, (options[:file] || '(file)')

      @code_gen = Opal::CodeGenerator.new
      @code_gen.generate @sexp, options
    end

    def requires
      @code_gen.requires
    end
  end
end

