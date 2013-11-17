require 'native'

describe "Native()" do
  it "should return nil for null or undefined" do
    Native(`null`).should be_nil
    Native(`undefined`).should be_nil
  end
end
