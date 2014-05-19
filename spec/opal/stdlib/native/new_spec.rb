require 'native'

describe "Native()" do
  it "should return nil for null or undefined" do
    expect(Native(`null`)).to be_nil
    expect(Native(`undefined`)).to be_nil
  end
end
