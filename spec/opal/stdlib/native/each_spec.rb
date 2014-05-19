require 'native'

describe "Native::Object#each" do
  it "enumerates on object properties" do
    Native(`{ a: 2, b: 3 }`).each {|name, value|
      expect((name == :a && value == 2) || (name == :b && value == 3)).to be_true
    }
  end

  it "accesses the native when no block is given" do
    expect(Native(`{ a: 2, b: 3, each: function() { return 42; } }`).each).to eq(42)
  end
end
