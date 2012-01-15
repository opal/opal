require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Array#fetch" do
  it "returns the element at the passed index" do
    [1, 2, 3].fetch(1).should == 2
    [nil].fetch(0).should == nil
  end

  it "counts negative indices backwards from end" do
    [1, 2, 3, 4].fetch(-1).should == 4
  end

  it "raises an IndexError id there is no element at index" do
    lambda { [1, 2, 3].fetch(3) }.should raise_error(IndexError)
    lambda { [1, 2, 3].fetch(-4) }.should raise_error(IndexError)
    lambda { [].fetch(0) }.should raise_error(IndexError)
  end

  it "returns default if there is no element at index if passed a default value" do
    [1, 2, 3].fetch(5, :not_found).should == :not_found
    [1, 2, 3].fetch(5, nil).should == nil
    [1, 2, 3].fetch(-4, :not_found).should == :not_found
    [nil].fetch(0, :not_found).should == nil
  end
end
