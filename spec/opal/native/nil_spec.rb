describe "Native#nil?" do
  it "returns true for wrapped null" do
    Native(`null`).nil?.should be_true
  end

  it "returns true for wrapped undefined" do
    Native(`undefined`).nil?.should be_true
  end

  it "returns false for everything else" do
    Native(`false`).nil?.should be_false
    Native(`{}`).nil?.should be_false
  end
end
