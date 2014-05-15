require 'native'

describe "Native::Object#method_missing" do
  it "should return values" do
    expect(Native(`{ a: 23 }`).a).to eq(23)
    expect(Native(`{ a: { b: 42 } }`).a.b).to eq(42)
  end

  it "should call functions" do
    expect(Native(`{ a: function() { return 42 } }`).a).to eq(42)
  end

  it "should pass the proper this to functions" do
    %x{
      function foo() {
        this.baz = 42;
      }

      foo.prototype.bar = function () {
        return this.baz;
      }
    }

    obj = `new foo()`
    expect(Native(obj).bar).to eq(42)
    Native(obj).baz = 23
    expect(Native(obj).bar).to eq(23)
  end

  it "should set values" do
    var = `{}`

    Native(var).a = 42
    expect(`#{var}.a`).to eq(42)
    expect(Native(var).a).to eq(42)
  end

  it "should pass the block as function" do
    expect(Native(`{ a: function(func) { return func(); } }`).a { 42 }).to eq(42)
  end

  it "should unwrap arguments" do
    x = `{}`

    expect(Native(`{ a: function(a, b) { return a === b } }`).a(Native(x), x)).to eq(true)
  end

  it "should wrap result" do
    expect(Native(`{ a: function() { return {}; } }`).a.class).to eq(Native::Object)
  end
end
