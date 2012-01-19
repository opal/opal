require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Array#delete" do
  it "removes elements that are #== to object" do
    x = mock('delete')
    def x.==(other) 3 == other end

    a = [1, 2, 3, x, 4, 3, 5, x]
    a.delete mock('not contained')

    a.delete 3
    a.should == [1, 2, 4, 5]
  end

  it "calculates equality correctly for reference values" do
    a = ["foo", "bar", "foo", "quux", "foo"]
    a.delete "foo"
    a.should == ["bar", "quux"]
  end

  it "returns object or nil if no elements match object" do
    [1, 2, 4, 5].delete(1).should == 1
    [1, 2, 4, 5].delete(3).should == nil
  end
end
