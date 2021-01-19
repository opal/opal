require 'lib/spec_helper'
require 'support/rewriters_helper'
require 'opal/rewriters/for_rewriter'

RSpec.describe Opal::Rewriters::ReturnableLogic do
  include RewritersHelper
  extend  RewritersHelper

  include_examples 'it rewrites source-to-AST', 'true or false', s(:if,
    s(:lvasgn, "$ret_or_1", s(:true)),
    s(:js_tmp, "$ret_or_1"),
    s(:false)
  )

  include_examples 'it rewrites source-to-AST', 'true and false', s(:if,
    s(:lvasgn, "$ret_or_1", s(:true)),
    s(:false),
    s(:js_tmp, "$ret_or_1")
  )

  include_examples 'it rewrites source-to-AST', 'true or next', s(:if,
    s(:lvasgn, "$ret_or_1", s(:true)),
    s(:js_tmp, "$ret_or_1"),
    s(:next)
  )

  include_examples 'it rewrites source-to-AST', 'true and next', s(:if,
    s(:lvasgn, "$ret_or_1", s(:true)),
    s(:next),
    s(:js_tmp, "$ret_or_1")
  )

  include_examples 'it rewrites source-to-AST', 'true or false or maybe', s(:if,
    s(:lvasgn, "$ret_or_1", s(:if,
      s(:lvasgn, "$ret_or_2", s(:true)),
      s(:js_tmp, "$ret_or_2"),
      s(:false)
    )),
    s(:js_tmp, "$ret_or_1"),
    s(:send, nil, :maybe)
  )

  include_examples 'it rewrites source-to-AST', 'true and false and surely', s(:if,
    s(:lvasgn, "$ret_or_1", s(:if,
      s(:lvasgn, "$ret_or_2", s(:true)),
      s(:false),
      s(:js_tmp, "$ret_or_2")
    )),
    s(:send, nil, :surely),
    s(:js_tmp, "$ret_or_1")
  )
end
