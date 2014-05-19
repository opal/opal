describe "Kernel#nil?" do
  it "should return false for all object that are not nil" do
    expect(Object.new.nil?).to be_false
    expect(0.nil?).to be_false
    expect(false.nil?).to be_false
  end
end