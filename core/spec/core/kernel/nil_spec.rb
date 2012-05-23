describe "Kernel#nil?" do
  it "should return false for all object that are not nil" do
    Object.new.nil?.should be_false
    0.nil?.should be_false
    false.nil?.should be_false
  end
end