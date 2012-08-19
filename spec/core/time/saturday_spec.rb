describe "Time#saturday?" do
  it "returns true if time represents Saturday" do
    Time.new(2000, 1, 1).saturday?.should == true
  end

  it "returns false if time doesn't represent Saturday" do
    Time.new(2000, 1, 2).saturday?.should == false
  end
end