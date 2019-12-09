require 'lib/spec_helper'
require 'support/rewriters_helper'
require 'opal/rewriters/for_rewriter'

RSpec.describe Opal::Rewriters::ForRewriter do
  include RewritersHelper
  extend  RewritersHelper

  before(:each) { Opal::Rewriters::ForRewriter.reset_tmp_counter! }

  include_examples 'it rewrites source-to-AST', 'for i in (0..3); for j in (4..6); a = i + j; end; end', s(:begin,
    s(:lvdeclare, :i),
    s(:lvdeclare, :j),
    s(:lvdeclare, :a),
    s(:send,
      ast_of('(0..3)'),
      :each,
      s(:iter,
        s(:args,
          s(:arg, :$for_tmp1)),
        s(:begin,
          s(:initialize_iter_arg, :$for_tmp1),
          s(:lvasgn, :i,
            s(:js_tmp, :$for_tmp1)),
          s(:begin,
            s(:lvdeclare, :j),
            s(:lvdeclare, :a),
            s(:send,
              ast_of('(4..6)'),
              :each,
              s(:iter,
                s(:args,
                  s(:arg, :$for_tmp2)),
                s(:begin,
                  s(:initialize_iter_arg, :$for_tmp2),
                  s(:lvasgn, :j,
                    s(:js_tmp, :$for_tmp2)),
                  s(:lvasgn, :a,
                    s(:send,
                      s(:lvar, :i), :+,
                      s(:lvar, :j)
                    )
                  )
                )
              )
            )
          )
        )
      )
    )
  )

  include_examples 'it rewrites source-to-AST', 'for i in (0..3); a = 1; b = 2; end', s(:begin,
    s(:lvdeclare, :i),
    s(:lvdeclare, :a),
    s(:lvdeclare, :b),
    s(:send,
      ast_of('(0..3)'),
      :each,
      s(:iter,
        s(:args, s(:arg, :$for_tmp1)),
        s(:begin,
          s(:initialize_iter_arg, :$for_tmp1),
          s(:lvasgn, :i, s(:js_tmp, :$for_tmp1)),
          ast_of('a = 1'),
          ast_of('b = 2')
        )
      )
    )
  )

  include_examples 'it rewrites source-to-AST', 'for i, j in obj; a = 1; b, c = 2, 3; end', s(:begin,
    s(:lvdeclare, :i),
    s(:lvdeclare, :j),
    s(:lvdeclare, :a),
    s(:lvdeclare, :b),
    s(:lvdeclare, :c),
    s(:send,
      ast_of('obj'),
      :each,
      s(:iter,
        s(:args, s(:arg, :$for_tmp1)),
        s(:begin,
          s(:initialize_iter_arg, :$for_tmp1),
          s(:masgn, s(:mlhs, s(:lvasgn, :i), s(:lvasgn, :j)), s(:js_tmp, :$for_tmp1)),
          ast_of('a = 1'),
          ast_of('b, c = 2, 3')
        )
      )
    )
  )
end
