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
end