describe "Array literals" do
  it "[] accepts a literal hash without curly braces as its last parameter" do
    expect(["foo", "bar" => :baz]).to eq(["foo", {"bar" => :baz}])
    expect([1, 2, 3 => 6, 4 => 24]).to eq([1, 2, {3 => 6, 4 => 24}])
  end

  it "[] treats splatted nil as no element" do
    expect([*nil]).to eq([])
    expect([1, *nil]).to eq([1])
    expect([1, 2, *nil]).to eq([1, 2])
    expect([1, *nil, 3]).to eq([1, 3])
    expect([*nil, *nil, *nil]).to eq([])
  end
end

describe "The unpacking splat operator (*)" do
  it "when applied to a non-Array value attempts to coerce it to Array if the object respond_to?(:to_a)" do
    obj = double("pseudo-array")
    expect(obj).to receive(:to_a).and_return([2, 3, 4])
    expect([1, *obj]).to eq([1, 2, 3, 4])
  end

  it "when applied to a non-Array value uses it unchanged if it does not respond_to?(:to_a)" do
    obj = Object.new
    expect(obj).not_to respond_to(:to_a)
    expect([1, *obj]).to eq([1, obj])
  end

  it "can be used before other non-splat elements" do
    a = [1, 2]
    expect([0, *a, 3]).to eq([0, 1, 2, 3])
  end

  it "can be used multiple times in the same containing array" do
    a = [1, 2]
    b = [1, 0]
    expect([*a, 3, *a, *b]).to eq([1, 2, 3, 1, 2, 1, 0])
  end
end
