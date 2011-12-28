require File.expand_path('../../spec_helper', __FILE__)

describe "Basic assignment" do
  it "allows the rhs to be assigned to the lhs" do
    a = nil
    a.should == nil
  end

  it "assigns nil to lhs when rhs is an empty expression" do
    a = ()
    a.should be_nil
  end

  it "assigns [] to lhs when rhs is an empty splat expression" do
    a = *()
    a.should == []
  end

  it "allows the assignment of the rhs to the lhs using the rhs splat operator" do
    a = *nil;       a.should == []
    a = *1;         a.should == [1]
    a = *[];        a.should == []
    a = *[1];       a.should == [1]
    a = *[nil];     a.should == [nil]
    a = *[[]];      a.should == [[]]
    a = *[1,2];     a.should == [1,2]
  end
end
