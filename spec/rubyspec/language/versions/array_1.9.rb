describe "Array literals" do
  it "[] accepts a literal hash without curly braces as its last parameter" do
    ["foo", "bar" => :baz].should == ["foo", {"bar" => :baz}]
    [1, 2, 3 => 6, 4 => 24].should == [1, 2, {3 => 6, 4 => 24}]
  end

  it "[] treats splatted nil as no element" do
    [*nil].should == []
    [1, *nil].should == [1]
    [1, 2, *nil].should == [1, 2]
    [1, *nil, 3].should == [1, 3]
    [*nil, *nil, *nil].should == []
  end
end

describe "The unpacking splat operator (*)" do
  it "when applied to a non-Array value attempts to coerce it to Array if the object respond_to?(:to_a)" do
    obj = mock("pseudo-array")
    obj.should_receive(:to_a).and_return([2, 3, 4])
    [1, *obj].should == [1, 2, 3, 4]
  end

  it "when applied to a non-Array value uses it unchanged if it does not respond_to?(:to_a)" do
    obj = Object.new
    obj.should_not respond_to(:to_a)
    [1, *obj].should == [1, obj]
  end

  it "can be used before other non-splat elements" do
    a = [1, 2]
    [0, *a, 3].should == [0, 1, 2, 3]
  end

  it "can be used multiple times in the same containing array" do
    a = [1, 2]
    b = [1, 0]
    [*a, 3, *a, *b].should == [1, 2, 3, 1, 2, 1, 0]
  end
end
