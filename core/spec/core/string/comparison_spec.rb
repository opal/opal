describe "String#<=>" do
  it "returns -1 when self is less than other" do
    ("this" <=> "those").should == -1
  end

  it "returns 0 when self is equal to other" do
    ("yep" <=> "yep").should == 0
  end

  it "returns 1 when self is greater than other" do
    ("yoddle" <=> "griddle").should == 1
  end
end