describe "Proc#[]" do
  it "invokes self" do
    expect(Proc.new { "test!" }[]).to eq("test!")
    expect(lambda { "test!" }[]).to eq("test!")
    expect(proc { "test!" }[]).to eq("test!")
  end

  it "sets self's parameters to the given values" do
    expect(Proc.new { |a, b| a + b }[1, 2]).to eq(3)
    expect(Proc.new { |*args| args }[1, 2, 3, 4]).to eq([1, 2, 3, 4])
    expect(Proc.new { |_, *args| args }[1, 2, 3]).to eq([2, 3])

    expect(lambda { |a, b| a + b }[1, 2]).to eq(3)
    expect(lambda { |*args| args }[1, 2, 3, 4]).to eq([1, 2, 3, 4])
    expect(lambda { |_, *args| args }[1, 2, 3]).to eq([2, 3])

    expect(proc { |a, b| a + b }[1, 2]).to eq(3)
    expect(proc { |*args| args }[1, 2, 3, 4]).to eq([1, 2, 3, 4])
    expect(proc { |_, *args| args }[1, 2, 3]).to eq([2, 3])
  end
end
