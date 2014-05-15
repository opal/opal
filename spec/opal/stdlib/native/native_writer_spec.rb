require 'native'

describe "Native.native_writer" do
  it "refers to an attribute on @native" do
    n = Class.new {
      include Native

      native_reader :a
      native_writer :a
    }.new(`{ a: 2 }`)

    n.a = 4
    expect(n.a).to eq(4)
  end

  it "supports multiple names" do
    n = Class.new {
      include Native

      native_reader :a, :b
      native_writer :a, :b
    }.new(`{ a: 2, b: 3 }`)

    n.a = 4
    n.b = 5

    expect(n.a).to eq(4)
    expect(n.b).to eq(5)
  end
end
