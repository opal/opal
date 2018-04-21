# frozen_string_literal: true

begin
  require 'c_lexer'
rescue LoadError
  $stderr.puts 'Failed to load CLexer, using pure Ruby lexer'
end

if defined? Parser::Ruby25WithCLexer
  class Opal::Parser::WithCLexer < Parser::Ruby25WithCLexer
    include Opal::Parser::DefaultConfig
    Opal::Parser.default_parser_class = self
  end
end
