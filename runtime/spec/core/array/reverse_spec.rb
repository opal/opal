require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Array#reverse" do
  it "returns a new array with the elements in reverse order" do
    [].reverse.should == []
    [1, 3, 5, 2].reverse.should == [2, 5, 3, 1]
  end
end
