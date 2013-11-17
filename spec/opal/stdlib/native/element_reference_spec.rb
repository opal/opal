require 'native'

describe "Native::Object#[]" do
  it "should return the same value for bridged classes" do
    Native(`2`).should === 2
    Native(`"lol"`).should === "lol"
  end

  it "should return functions as is" do
    Native(`{ a: function(){} }`)[:a].should be_kind_of Proc
  end

  it "should wrap natives into a Native object" do
    Native(`{ a: { b: 2 } }`)[:a][:b].should == 2
  end
end
