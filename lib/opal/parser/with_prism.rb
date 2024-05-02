# frozen_string_literal: true

require 'prism'
require 'prism/translation/parser'

class Opal::Parser::WithPrism < ::Prism::Translation::Parser
  include Opal::Parser::DefaultConfig

  def build_ast(program, offset_cache)
    modify_ast(super)
  end
end
