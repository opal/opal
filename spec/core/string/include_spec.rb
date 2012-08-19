describe "String#include?" do
  it "returns true if self contains other_str" do
    "hello".include?("lo").should == true
    "hello".include?("ol").should == false
  end

  it "ignores subclass differences" do
    "hello".include?(StringSpecs::MyString.new("lo")).should == true
    StringSpecs::MyString.new("hello").include?("lo").should == true
    StringSpecs::MyString.new("hello").include?(StringSpecs::MyString.new("lo")).should == true
  end
end