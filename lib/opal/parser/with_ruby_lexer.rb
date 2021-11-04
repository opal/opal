# frozen_string_literal: true

class Opal::Parser::WithRubyLexer < Parser::Ruby31
  include Opal::Parser::DefaultConfig
  Opal::Parser.default_parser_class = self
end
