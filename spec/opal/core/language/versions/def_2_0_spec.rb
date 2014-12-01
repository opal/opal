# TODO: this should be loaded from rubyspec instead

describe "An instance method with keyword arguments" do
  context "when there is a single keyword argument" do
    before do
      def foo(a: 1)
        a
      end
    end

    it "evaluates to the default when a value isn't provided" do
      foo.should == 1
    end

    it "evaluates to the provided value" do
      foo(a: 20).should == 20
      foo(a: nil).should be_nil
    end

    it "raises an argument error when an unknown keyword argument is provided" do
      lambda { foo(b: 20) }.should raise_error(ArgumentError)
    end

    it "raises an argument error when a non-keyword argument is provided" do
      lambda { foo(1) }.should raise_error(ArgumentError)
    end
  end

  it "treats a sole hash argument correctly" do
    def foo(a, b: 10)
      [a, b]
    end
    foo(b: "b").should == [{:b => "b"}, 10]
    foo("a", b: "b").should == ["a", "b"]
  end

  it "correctly distinguishes between optional and keyword arguments" do
    def foo(a = true, b: 10)
      [a, b]
    end
    foo(b: 42).should == [true, 42]
    foo(false, b: 42).should == [false, 42]
  end

  it "correctly distinguishes between rest and keyword arguments" do
    def foo(*a, b: 10)
      [a, b]
    end
    foo(1, 2, 3, 4).should == [[1, 2, 3, 4], 10]
    foo(1, 2, 3, 4, b: 42).should == [[1, 2, 3, 4], 42]
    foo(b: 42).should == [[], 42]
  end

  it "should allow keyword rest arguments" do
    def foo(a: 1, **b)
      [a, b]
    end
    foo(b: 2, c: 3, d: 4).should == [1, {:b => 2, :c => 3, :d => 4}]
    foo(a: 4, b: 2).should == [4, {:b => 2}]
    foo.should == [1, {}]
  end
end
