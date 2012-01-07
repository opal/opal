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

describe "Assigning multiple values" do
  it "allows parallel assignment" do
    a, b = 1, 2
    a.should == 1
    b.should == 2

    a, = 1,2
    a.should == 1
  end

  it "allows safe parallel swapping" do
    a, b = 1, 2
    a, b = b, a
    a.should == 2
    b.should == 1
  end

  it "bundles remaining values to an array when using the splat operator" do
    a, *b = 1, 2, 3
    a.should == 1
    b.should == [2, 3]

    *a = 1, 2, 3
    a.should == [1, 2, 3]

    *a = 4
    a.should == [4]

    *a = nil
    a.should == [nil]
  end
end
