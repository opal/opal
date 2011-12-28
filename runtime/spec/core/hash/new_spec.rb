require File.expand_path('../../../spec_helper', __FILE__)

describe "Hash.new" do
  it "creates an empty Hash if passed no arguments" do
    Hash.new.should == {}
    Hash.new.size.should == 0
  end

  it "creates a new Hash with default object if passed a default argument" do
    Hash.new(5).default.should == 5
    Hash.new({}).default.should == {}
  end
end
