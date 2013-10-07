require 'spec_helper'

describe "Parens" do
  it "can be used to group expressions" do
    (self.class; self.to_s; 42).should == 42
    (3.142).should == 3.142
    ().should == nil
  end

  it "generates code that contains the expression in precedence" do
    foo = 100
    ((foo += 42) == 142).should == true
  end
end
