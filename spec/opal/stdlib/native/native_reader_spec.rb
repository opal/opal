require 'native'

describe "Native.native_reader" do
  it "refers to an attribute on @native" do
    Class.new {
      include Native

      native_reader :a
    }.new(`{ a: 2 }`).a.should == 2
  end

  it "uses multiple names" do
    n = Class.new {
      include Native

      native_reader :a, :b
    }.new(`{ a: 2, b: 3 }`)

    n.a.should == 2
    n.b.should == 3
  end
end
