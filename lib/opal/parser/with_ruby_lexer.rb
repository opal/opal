# frozen_string_literal: true

class Opal::Parser::WithRubyLexer < Parser::Ruby32
  include Opal::Parser::DefaultConfig

  def parse(source_buffer)
    modify_ast(super)
  end
end
