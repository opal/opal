# frozen_string_literal: true

# There's no compatible c_lexer for parser 3.0.0.0 at this point...
begin
  require 'c_lexer'
rescue LoadError
  $stderr.puts 'Failed to load WithCLexer, using pure Ruby lexer' if $DEBUG
end

if defined? Parser::Ruby25WithWithCLexer
  class Opal::Parser::WithCLexer < Parser::Ruby25WithWithCLexer
    include Opal::Parser::DefaultConfig
    Opal::Parser.default_parser_class = self
  end
end
