require 'spec_helper'

describe "Opal.uid()" do
  it "returns even sequential numbers in increments of 2" do
    %x{
      var id0 = Opal.uid(),
          id1 = Opal.uid(),
          id2 = Opal.uid(),
          id3 = Opal.uid(),
          id4 = Opal.uid();
    }

    modulo = `id0` % 2
    modulo.should == 0

    `id1`.should == `id0` + 2
    `id2`.should == `id0` + 4
    `id3`.should == `id0` + 6
    `id4`.should == `id0` + 8
  end
end

describe "FalseClass#object_id" do
  it "returns 0" do
    false.object_id.should == 0
  end
end

describe "TrueClass#object_id" do
  it "returns 2" do
    true.object_id.should == 2
  end
end

describe "NilClass#object_id" do
  it "returns 4" do
    nil.object_id.should == 4
  end
end

describe "Numeric#object_id" do
  it "returns (self * 2) + 1" do
    0.object_id.should == 1
    1.object_id.should == 3
    2.object_id.should == 5
    420.object_id.should == 841
    -2.object_id.should == -3
    -1.object_id.should == -1
  end
end

describe "String#object_id" do
  it "returns the primitive string version of self" do
    `#{"hello".object_id} === "hello".toString()`.should be_true
  end
end
