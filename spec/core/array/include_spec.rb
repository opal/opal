
describe "Array#include?" do
  it "returns true if object is present, false otherwise" do
    [1, 2, "a", "b"].include?("c").should == false
    [1, 2, "a", "b"].include?("a").should == true
  end
  
  it "determines presence by using element == obj"
end
