# frozen_string_literal: true

require 'opal/ast/builder'
require 'opal/rewriter'
require 'opal/parser/source_buffer'
require 'opal/parser/default_config'
require 'opal/parser/with_ruby_lexer'

if RUBY_ENGINE == 'opal'
  require 'opal/parser/patch'
else
  require 'opal/parser/with_c_lexer'
end
