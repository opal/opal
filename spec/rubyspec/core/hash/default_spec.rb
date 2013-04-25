describe "Hash#default" do
  it "returns the default value" do
    h = Hash.new 5
    h.default.should == 5
    h.default(4).should == 5
    Hash.new.default.should == nil
    Hash.new.default(4).should == nil
  end
end

describe "Hash#default=" do
  it "sets the default value" do
    h = {}
    h.default = 99
    h.default.should == 99
  end
end