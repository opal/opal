require 'spec_helper'

class OpalReturnSpec
  def returning_expression
    (false || return)
  end

  def returning_block
    @values = []

    [1, 2, 3, 4, 5].each do |n|
      return if n == 3
      @values << n
    end
  end

  attr_reader :values

  def returning_block_value
    [1, 2, 3, 4, 5].each { return :foo }
  end
end

describe "The return statement" do
  it "can be used as an expression" do
    OpalReturnSpec.new.returning_expression.should be_nil
  end

  it "can return from a method when inside a block" do
    spec = OpalReturnSpec.new
    spec.returning_block
    spec.values.size.should == 2
  end

  it "returns the return value from a method returning by block" do
    OpalReturnSpec.new.returning_block_value.should == :foo
  end
end
