require 'lib/spec_helper'
require 'support/rewriters_helper'
require 'opal/rewriters/forward_args'

RSpec.describe Opal::Rewriters::ForwardArgs do
  include RewritersHelper

  before(:each) { Opal::Rewriters::ForRewriter.reset_tmp_counter! }

  correct_names = proc do |ast|
    case ast
    when Opal::AST::Node
      ast.children.map do |i|
        correct_names.(i)
      end.yield_self { |children| s(ast.type, *children) }
    when :fwd_rest
      "$fwd_rest"
    when :fwd_block
      "$fwd_block"
    else
      ast
    end
  end

  include_examples 'it rewrites source-to-AST', <<~ENDSOURCE, correct_names.(ast_of(<<~ENDDEST))
    def forward(...)
      other(...)
    end
  ENDSOURCE
    def forward(*fwd_rest, &fwd_block)
      other(*fwd_rest, &fwd_block)
    end
  ENDDEST

  include_examples 'it rewrites source-to-AST', <<~ENDSOURCE, correct_names.(ast_of(<<~ENDDEST))
    def forward(first_arg, ...)
      other(first_arg, second_arg, ...)
      other(other_arg, ...)
      other(...)
    end
  ENDSOURCE
    def forward(first_arg, *fwd_rest, &fwd_block)
      other(first_arg, second_arg, *fwd_rest, &fwd_block)
      other(other_arg, *fwd_rest, &fwd_block)
      other(*fwd_rest, &fwd_block)
    end
  ENDDEST

  # Not supported by the parser (nor by the rewriter which would have to rearrange the arguments)

  # include_examples 'it rewrites source-to-AST', <<~ENDSOURCE, correct_names.(parse(<<~ENDDEST))
  #   def forward(a:, ...)
  #     other(...)
  #   end
  # ENDSOURCE
  #   def forward(*fwd_rest, a:, &fwd_block)
  #     other(*fwd_rest, &fwd_block)
  #   end
  # ENDDEST
end
