# frozen_string_literal: true

class Opal::Parser::WithRubyLexer < Parser::Ruby30
  include Opal::Parser::DefaultConfig
  Opal::Parser::DEFAULT_PARSER_CLASS = self
end
