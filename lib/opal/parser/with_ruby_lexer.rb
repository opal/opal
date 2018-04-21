class Opal::Parser::WithRubyLexer < Parser::Ruby25
  include Opal::Parser::DefaultConfig
  Opal::Parser.default_parser_class = self
end
