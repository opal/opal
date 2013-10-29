describe "Native#method_missing" do
  it "should return values" do
    Native(`{ a: 23 }`).a.should == 23
    Native(`{ a: { b: 42 } }`).a.b.should == 42
  end

  it "should call functions" do
    Native(`{ a: function() { return 42 } }`).a.should == 42
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
    Native(obj).bar.should == 42
    Native(obj).baz = 23
    Native(obj).bar.should == 23
  end

  it "should set values" do
    var = `{}`

    Native(var).a = 42
    `#{var}.a`.should == 42
    Native(var).a.should == 42
  end

  it "should pass the block as function" do
    Native(`{ a: function(func) { return func(); } }`).a { 42 }.should == 42
  end
end
