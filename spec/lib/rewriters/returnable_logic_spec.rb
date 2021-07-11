require 'lib/spec_helper'
require 'support/rewriters_helper'
require 'opal/rewriters/for_rewriter'

RSpec.describe Opal::Rewriters::ReturnableLogic do
  include RewritersHelper
  extend  RewritersHelper

  # OpalEngineCheck as a side effect will optimize out obviously truthy/falsy
  # instructions which is why we use :true, :false here.

  # In fact, ReturnableLogic doesn't concern itself with the type of the value,
  # so obviously those examples will work, just that they would be optimized
  # out later on.

  include_examples 'it rewrites source-to-AST', ':true or :false', s(:if,
    s(:lvasgn, "$ret_or_1", s(:sym, :true)),
    s(:js_tmp, "$ret_or_1"),
    s(:sym, :false)
  )

  include_examples 'it rewrites source-to-AST', ':true and :false', s(:if,
    s(:lvasgn, "$ret_or_1", s(:sym, :true)),
    s(:sym, :false),
    s(:js_tmp, "$ret_or_1")
  )

  include_examples 'it rewrites source-to-AST', ':true or next', s(:if,
    s(:lvasgn, "$ret_or_1", s(:sym, :true)),
    s(:js_tmp, "$ret_or_1"),
    s(:next)
  )

  include_examples 'it rewrites source-to-AST', ':true and next', s(:if,
    s(:lvasgn, "$ret_or_1", s(:sym, :true)),
    s(:next),
    s(:js_tmp, "$ret_or_1")
  )

  include_examples 'it rewrites source-to-AST', ':true or :false or maybe', s(:if,
    s(:lvasgn, "$ret_or_1", s(:if,
      s(:lvasgn, "$ret_or_2", s(:sym, :true)),
      s(:js_tmp, "$ret_or_2"),
      s(:sym, :false)
    )),
    s(:js_tmp, "$ret_or_1"),
    s(:send, nil, :maybe)
  )

  include_examples 'it rewrites source-to-AST', ':true and :false and surely', s(:if,
    s(:lvasgn, "$ret_or_1", s(:if,
      s(:lvasgn, "$ret_or_2", s(:sym, :true)),
      s(:sym, :false),
      s(:js_tmp, "$ret_or_2")
    )),
    s(:send, nil, :surely),
    s(:js_tmp, "$ret_or_1")
  )
end
