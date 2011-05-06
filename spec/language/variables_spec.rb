require File.expand_path('../../spec_helper', __FILE__)

describe "Basic assignment" do
  it "allows the rhs to be assigned to the lhs" do
    a = nil;       a.should == nil
    a = 1;         a.should == 1
    a = [];        a.should == []
    a = [1];       a.should == [1]
    a = [nil];     a.should == [nil]
    a = [[]];      a.should == [[]]
    a = [1,2];     a.should == [1, 2]
    a = [*[]];     a.should == []
    a = [*[1]];    a.should == [1]
    a = [*[1,2]];  a.should == [1, 2]
  end

  it "assigns nil to lhs when rhs is an empty expression" do
    a = ()
    a.should == nil
  end
end

