describe "Array#include?" do
  it "returns true if object is present, false otherwise" do
    [1, 2, "a", "b"].include?("c").should == false
    [1, 2, "a", "b"].include?("a").should == true
  end

  it "determines presence by using element == obj" do
    o = mock('')

    [1, 2, "a", "b"].include?(o).should == false

    def o.==(other); other == 'a'; end

    [1, 2, o, "b"].include?('a').should == true

    [1, 2.0, 3].include?(2).should == true
  end
end