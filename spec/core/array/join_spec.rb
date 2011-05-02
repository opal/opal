describe "Array#join" do
  it "returns an empty string if the Array is empty" do
    a = Array.new
    a.join(':').should == ""
  end
end
