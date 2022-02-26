require 'lib/spec_helper'
require 'support/rewriters_helper'
require 'opal/rewriters/numblocks'

RSpec.describe Opal::Rewriters::Numblocks do
  include RewritersHelper
  extend RewritersHelper # s() in example scope

  correct_names = proc do |ast|
    case ast
    when Opal::AST::Node
      ast.children.map do |i|
        correct_names.(i)
      end.yield_self { |children| s(ast.type, *children) }
    when :arg1 then :_1
    when :arg2 then :_2
    when :arg3 then :_3
    else
      ast
    end
  end

  include_examples 'it rewrites source-to-AST', <<~ENDSOURCE, correct_names.(ast_of(<<~ENDDEST))
    proc do
      _1
    end
  ENDSOURCE
    proc do |arg1|
      arg1
    end
  ENDDEST

  include_examples 'it rewrites source-to-AST', <<~ENDSOURCE, correct_names.(ast_of(<<~ENDDEST))
    proc do
      _3
    end
  ENDSOURCE
    proc do |arg1, arg2, arg3|
      arg3
    end
  ENDDEST
end
