describe "Hash#[]" do
  it "returns the value for the key" do
    obj = Object.new
    h = {1 => 2, 3 => 4, "foo" => "bar", obj => obj, [] => "baz"}
    h[1].should == 2
    h[3].should == 4
    h["foo"].should == "bar"
    h[obj].should == obj
  end

  it "returns nil as default default value" do
    {0 => 0}[5].should == nil
  end

  it "returns the default (immediate) value for missing keys" do
    h = Hash.new 5
    h[:a].should == 5
    h[:a] = 0
    h[:a].should == 0
    h[:b].should == 5
  end

  it "does not return default values for keys with nil values" do
    h = Hash.new 5
    h[:a] = nil
    h[:a].should == nil
  end

  it "returns the default (dynamic) value for missing keys" do
    h = Hash.new { |hsh, k| k.kind_of?(Numeric) ? hsh[k] = k + 2 : hsh[k] = k }
    h[1].should == 3
    h['this'].should == 'this'
    h.should == {1 => 3, 'this' => 'this'}

    i = 0
    h = Hash.new { |hsh, key| i += 1 }
    h[:foo].should == 1
    h[:foo].should == 2
    h[:bar].should == 3
  end
end