describe "Native::Base.alias_native" do
  it "refers to an attribute on @native" do
    Class.new {
      include Native::Base

      alias_native :a, :a
    }.new(`{ a: 2 }`).a.should == 2
  end

  it "refers to an attribute on @native and calls it if it's a function" do
    Class.new {
      include Native::Base

      alias_native :a, :a
    }.new(`{ a: function() { return 42; } }`).a.should == 42
  end

end
