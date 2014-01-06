require 'spec_helper'

describe "Operator calls" do
  before { @obj = {:value => 10} }

  it "compiles as a normal send method call" do
    @obj[:value] += 15
    @obj[:value].should == 25

    @obj[:value] -= 23
    @obj[:value].should == 2
  end
end
