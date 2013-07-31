require 'spec_helper'

class LangReturnExprSpec
  def returning_expression
    (false || return)
  end
end

describe "The return statement" do
  it "can be used as an expression" do
    LangReturnExprSpec.new.returning_expression.should be_nil
  end
end
