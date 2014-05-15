describe "Kernel#Array" do
  it "returns an Array containing the argument if it responds to neither #to_ary nor #to_a" do
    obj = double('obj')
    expect(Array(obj)).to eq([obj])
  end

  it "returns an empty Array when passed nil" do
    expect(Array(nil)).to eq([])
  end
end