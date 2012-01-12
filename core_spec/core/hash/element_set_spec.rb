require File.expand_path('../../../spec_helper', __FILE__)

describe "Hash#[]=" do
  it "associates the key with the value and return the value" do
    h = {:a => 1}
    (h[:b] = 2).should == 2
  end
end
