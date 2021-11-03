describe "a block with super" do
  it "can be used to define multiple methods" do
    block = proc {
      super()
    }

    c1 = Class.new {
      def foo; :foo; end
      def bar; :bar; end
      def foo_bar; [foo, bar]; end
    }

    c2 = Class.new(c1) {
      define_method :foo, block
      define_method :bar, block
      define_method :foo_bar, block
    }

    obj = c2.new
    obj.foo.should == :foo
    obj.bar.should == :bar
    obj.foo_bar.should == [:foo, :bar]
  end
end
