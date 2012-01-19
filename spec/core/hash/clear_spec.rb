require File.expand_path('../../../spec_helper', __FILE__)

describe "Hash#clear" do
  it "removes all key, value pairs" do
    h = {1 => 2, 3 => 4}
    h.clear.should equal(h)
    h.should == {}
  end

  it "does not remove default values" do
    h = {}
    h.default = 5
    h.clear
    h.default.should == 5

    h = {"a" => 100, "b" => 200}
    h.default = "Go fish"
    h.clear
    h["z"].should == "Go fish"
  end
end
