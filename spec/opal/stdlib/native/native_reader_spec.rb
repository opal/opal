require 'native'

describe "Native.native_reader" do
  it "refers to an attribute on @native" do
    expect(Class.new {
      include Native

      native_reader :a
    }.new(`{ a: 2 }`).a).to eq(2)
  end

  it "uses multiple names" do
    n = Class.new {
      include Native

      native_reader :a, :b
    }.new(`{ a: 2, b: 3 }`)

    expect(n.a).to eq(2)
    expect(n.b).to eq(3)
  end
end
