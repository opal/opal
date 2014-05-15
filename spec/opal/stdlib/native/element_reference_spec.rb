require 'native'

describe "Native::Object#[]" do
  it "should return the same value for bridged classes" do
    expect(Native(`2`)).to be === 2
    expect(Native(`"lol"`)).to be === "lol"
  end

  it "should return functions as is" do
    expect(Native(`{ a: function(){} }`)[:a]).to be_kind_of Proc
  end

  it "should wrap natives into a Native object" do
    expect(Native(`{ a: { b: 2 } }`)[:a][:b]).to eq(2)
  end
end
