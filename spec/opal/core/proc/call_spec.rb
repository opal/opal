describe "Proc#call" do
  it "invokes self" do
    expect(Proc.new { "test!" }.call).to eq("test!")
    expect(lambda { "test!" }.call).to eq("test!")
    expect(proc { "test!" }.call).to eq("test!")
  end

  it "sets self's parameters to the given values" do
    expect(Proc.new { |a, b| a + b }.call(1, 2)).to eq(3)
    expect(Proc.new { |*args| args }.call(1, 2, 3, 4)).to eq([1, 2, 3, 4])
    expect(Proc.new { |_, *args| args }.call(1, 2, 3)).to eq([2, 3])

    expect(lambda { |a, b| a + b }.call(1, 2)).to eq(3)
    expect(lambda { |*args| args }.call(1, 2, 3, 4)).to eq([1, 2, 3, 4])
    expect(lambda { |_, *args| args }.call(1, 2, 3)).to eq([2, 3])

    expect(proc { |a, b| a + b }.call(1, 2)).to eq(3)
    expect(proc { |*args| args }.call(1, 2, 3, 4)).to eq([1, 2, 3, 4])
    expect(proc { |_, *args| args }.call(1, 2, 3)).to eq([2, 3])
  end
end