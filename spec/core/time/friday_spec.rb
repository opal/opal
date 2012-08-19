describe "Time#friday?" do
  it "returns true if the time represents Friday" do
    Time.new(2000, 1, 7).friday?.should == true
  end

  it "returns false if time doesn't represent Friday" do
    Time.new(2000, 1, 1).friday?.should == false
  end
end