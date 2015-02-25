require 'native'

describe "Native.alias_native" do
  it "refers to an attribute on @native" do
    Class.new {
      include Native

      alias_native :a, :a
    }.new(`{ a: 2 }`).a.should == 2
  end

  it "refers to an attribute on @native and calls it if it's a function" do
    Class.new {
      include Native

      alias_native :a, :a
    }.new(`{ a: function() { return 42; } }`).a.should == 42
  end

  it "defaults old to new" do
    Class.new {
      include Native

      alias_native :a
    }.new(`{ a: 42 }`).a.should == 42
  end
end

describe 'Module#alias_native' do
  it 'exposes a native method' do
    klass = Class.new
    `klass.$$proto.a = function() { return 123 }`
    klass.alias_native :a, :a
    klass.new.a.should == 123
  end
end
