# frozen_string_literal: true

begin
  require 'c_lexer'
rescue LoadError
  $stderr.puts 'Failed to load WithCLexer, using pure Ruby lexer'
end

if defined? Parser::Ruby25WithWithCLexer
  class Opal::Parser::WithCLexer < Parser::Ruby25WithWithCLexer
    include Opal::Parser::DefaultConfig
    Opal::Parser.default_parser_class = self
  end
end
