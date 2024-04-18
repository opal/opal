require 'spec_helper'
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
    when :fwd_kwrest
      "$fwd_kwrest"
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
    def forward_star(*)
      other(*)
    end
  ENDSOURCE
    def forward_star(*fwd_rest)
      other(*fwd_rest)
    end
  ENDDEST

  include_examples 'it rewrites source-to-AST', <<~ENDSOURCE, correct_names.(ast_of(<<~ENDDEST))
    def forward_kwstar(**)
      other(**)
    end
  ENDSOURCE
    def forward_kwstar(**fwd_kwrest)
      other(**fwd_kwrest)
    end
  ENDDEST

  include_examples 'it rewrites source-to-AST', <<~ENDSOURCE, correct_names.(ast_of(<<~ENDDEST))
    def forward_block(&)
      other(&)
    end
  ENDSOURCE
    def forward_block(&fwd_block)
      other(&fwd_block)
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
end
