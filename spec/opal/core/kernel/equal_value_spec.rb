describe "Kernel#==" do
  it "returns true only if obj and other are the same object" do
    o1 = Object.new
    o2 = Object.new
    expect(o1 == o1).to eq(true)
    expect(o2 == o2).to eq(true)
    expect(o1 == o2).to eq(false)
    expect(nil == nil).to eq(true)
    expect(o1 == nil).to eq(false)
    expect(nil == o2).to eq(false)
  end
end