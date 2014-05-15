describe "Kernel#class" do
  it "returns the class of the receiver" do
    expect(Object.new.class).to eq(Object)
    expect([].class).to eq(Array)
  end
end