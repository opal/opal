require 'spec_helper'

describe "numblocks" do
  it "supports numblocks" do
    [1,2,3].map { _1 * 2 }.should == [2,4,6]
    [[1,2],[3,4]].map { _1 * _2 }.should == [2,12]
  end

  it "reports correct arity" do
    proc { [_1, _2] + [_3] }.arity.should == 3
  end

  it "reports correct parameters" do
    proc { [_1, _2] }.parameters.should == [[:opt, :_1], [:opt, :_2]]
  end
end
