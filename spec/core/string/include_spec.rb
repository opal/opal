describe "String#include?" do
  it "returns true if self contains other_str" do
    "hello".include?("lo").should == true
    "hello".include?("ol").should == false
  end
end