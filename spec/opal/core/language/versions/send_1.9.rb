# FIXME: Add error case
#
require File.expand_path("../../fixtures/send_1.9.rb", __FILE__)
require 'language/fixtures/send_1.9'

specs = LangSendSpecs

describe "Invoking a method" do
  describe "with required args after the rest arguments" do
    it "binds the required arguments first" do
      expect(specs.fooM0RQ1(1)).to eq([[], 1])
      expect(specs.fooM0RQ1(1,2)).to eq([[1], 2])
      expect(specs.fooM0RQ1(1,2,3)).to eq([[1,2], 3])

      expect(specs.fooM1RQ1(1,2)).to eq([1, [], 2])
      expect(specs.fooM1RQ1(1,2,3)).to eq([1, [2], 3])
      expect(specs.fooM1RQ1(1,2,3,4)).to eq([1, [2, 3], 4])

      expect(specs.fooM1O1RQ1(1,2)).to eq([1, 9, [], 2])
      expect(specs.fooM1O1RQ1(1,2,3)).to eq([1, 2, [], 3])
      expect(specs.fooM1O1RQ1(1,2,3,4)).to eq([1, 2, [3], 4])

      expect(specs.fooM1O1RQ2(1,2,3)).to eq([1, 9, [], 2, 3])
      expect(specs.fooM1O1RQ2(1,2,3,4)).to eq([1, 2, [], 3, 4])
      expect(specs.fooM1O1RQ2(1,2,3,4,5)).to eq([1, 2, [3], 4, 5])
    end
  end

  describe "with manditory arguments after optional arguments" do
    it "binds the required arguments first" do
      expect(specs.fooO1Q1(0,1)).to eq([0,1])
      expect(specs.fooO1Q1(2)).to eq([1,2])

      expect(specs.fooM1O1Q1(2,3,4)).to eq([2,3,4])
      expect(specs.fooM1O1Q1(1,3)).to eq([1,2,3])

      expect(specs.fooM2O1Q1(1,2,4)).to eq([1,2,3,4])

      expect(specs.fooM2O2Q1(1,2,3,4,5)).to eq([1,2,3,4,5])
      expect(specs.fooM2O2Q1(1,2,3,5)).to eq([1,2,3,4,5])
      expect(specs.fooM2O2Q1(1,2,5)).to eq([1,2,3,4,5])

      expect(specs.fooO4Q1(1,2,3,4,5)).to eq([1,2,3,4,5])
      expect(specs.fooO4Q1(1,2,3,5)).to eq([1,2,3,4,5])
      expect(specs.fooO4Q1(1,2,5)).to eq([1,2,3,4,5])
      expect(specs.fooO4Q1(1,5)).to eq([1,2,3,4,5])
      expect(specs.fooO4Q1(5)).to eq([1,2,3,4,5])

      expect(specs.fooO4Q2(1,2,3,4,5,6)).to eq([1,2,3,4,5,6])
      expect(specs.fooO4Q2(1,2,3,5,6)).to eq([1,2,3,4,5,6])
      expect(specs.fooO4Q2(1,2,5,6)).to eq([1,2,3,4,5,6])
      expect(specs.fooO4Q2(1,5,6)).to eq([1,2,3,4,5,6])
      expect(specs.fooO4Q2(5,6)).to eq([1,2,3,4,5,6])
    end
  end

  it "with .() invokes #call" do
    q = proc { |z| z }
    expect(q.(1)).to eq(1)

    obj = double("paren call")
    expect(obj).to receive(:call).and_return(:called)
    expect(obj.()).to eq(:called)
  end

  it "allows a vestigial trailing ',' in the arguments" do
    # specs.fooM1(1,).should == [1]
  end

  it "with splat operator attempts to coerce it to an Array if the object respond_to?(:to_a)" do
    ary = [2,3,4]
    obj = double("to_a")
    expect(obj).to receive(:to_a).and_return(ary).twice
    expect(specs.fooM0R(*obj)).to eq(ary)
    expect(specs.fooM1R(1,*obj)).to eq([1, ary])
  end

  it "with splat operator * and non-Array value uses value unchanged if it does not respond_to?(:to_ary)" do
    obj = Object.new
    expect(obj).not_to respond_to(:to_a)

    expect(specs.fooM0R(*obj)).to eq([obj])
    expect(specs.fooM1R(1,*obj)).to eq([1, [obj]])
  end

  it "accepts additional arguments after splat expansion" do
    a = [1,2]
    expect(specs.fooM4(*a,3,4)).to eq([1,2,3,4])
    expect(specs.fooM4(0,*a,3)).to eq([0,1,2,3])
  end

  it "accepts final explicit literal Hash arguments after the splat" do
    a = [1, 2]
    expect(specs.fooM0RQ1(*a, { :a => 1 })).to eq([[1, 2], { :a => 1 }])
  end

  it "accepts final implicit literal Hash arguments after the splat" do
    a = [1, 2]
    expect(specs.fooM0RQ1(*a, :a => 1)).to eq([[1, 2], { :a => 1 }])
  end

  it "accepts final Hash arguments after the splat" do
    a = [1, 2]
    b = { :a => 1 }
    expect(specs.fooM0RQ1(*a, b)).to eq([[1, 2], { :a => 1 }])
  end

  it "accepts mandatory and explicit literal Hash arguments after the splat" do
    a = [1, 2]
    expect(specs.fooM0RQ2(*a, 3, { :a => 1 })).to eq([[1, 2], 3, { :a => 1 }])
  end

  it "accepts mandatory and implicit literal Hash arguments after the splat" do
    a = [1, 2]
    expect(specs.fooM0RQ2(*a, 3, :a => 1)).to eq([[1, 2], 3, { :a => 1 }])
  end

  it "accepts mandatory and Hash arguments after the splat" do
    a = [1, 2]
    b = { :a => 1 }
    expect(specs.fooM0RQ2(*a, 3, b)).to eq([[1, 2], 3, { :a => 1 }])
  end

  it "converts a final splatted explicit Hash to an Array" do
    a = [1, 2]
    expect(specs.fooR(*a, 3, *{ :a => 1 })).to eq([1, 2, 3, [:a, 1]])
  end

  it "calls #to_a to convert a final splatted Hash object to an Array" do
    a = [1, 2]
    b = { :a => 1 }
    expect(b).to receive(:to_a).and_return([:a, 1])

    expect(specs.fooR(*a, 3, *b)).to eq([1, 2, 3, :a, 1])
  end

  it "accepts multiple splat expansions in the same argument list" do
    a = [1,2,3]
    b = 7
    c = double("pseudo-array")
    expect(c).to receive(:to_a).and_return([0,0])

    d = [4,5]
    expect(specs.rest_len(*a,*d,6,*b)).to eq(7)
    expect(specs.rest_len(*a,*a,*a)).to eq(9)
    expect(specs.rest_len(0,*a,4,*5,6,7,*c,-1)).to eq(11)
  end

  it "expands an array to arguments grouped in parentheses" do
    expect(specs.destructure2([40,2])).to eq(42)
  end

  it "expands an array to arguments grouped in parentheses and ignores any rest arguments in the array" do
    expect(specs.destructure2([40,2,84])).to eq(42)
  end

  it "expands an array to arguments grouped in parentheses and sets not specified arguments to nil" do
    expect(specs.destructure2b([42])).to eq([42, nil])
  end

  it "expands an array to arguments grouped in parentheses which in turn takes rest arguments" do
    expect(specs.destructure4r([1, 2, 3])).to eq([1, 2, [], 3, nil])
    expect(specs.destructure4r([1, 2, 3, 4])).to eq([1, 2, [], 3, 4])
    expect(specs.destructure4r([1, 2, 3, 4, 5])).to eq([1, 2, [3], 4, 5])
  end

  describe "new-style hash arguments" do
    describe "as the only parameter" do
      it "passes without curly braces" do
        expect(specs.fooM1(rbx: 'cool', specs: :fail_sometimes, non_sym: 1234)).to eq(
          [{ :rbx => 'cool', :specs => :fail_sometimes, :non_sym => 1234 }]
        )
      end

      it "passes without curly braces or parens" do
        expect(specs.fooM1 rbx: 'cool', specs: :fail_sometimes, non_sym: 1234).to eq(
          [{ :rbx => 'cool', :specs => :fail_sometimes, :non_sym => 1234 }]
        )
      end

      it "handles a hanging comma without curly braces" do
        # specs.fooM1(abc: 123,).should == [{:abc => 123}]
        # specs.fooM1(rbx: 'cool', specs: :fail_sometimes, non_sym: 1234,).should ==
          # [{ :rbx => 'cool', :specs => :fail_sometimes, :non_sym => 1234 }]
      end
    end

    describe "as the last parameter" do
      it "passes without curly braces" do
        expect(specs.fooM3('abc', 123, rbx: 'cool', specs: :fail_sometimes, non_sym: 1234)).to eq(
          ['abc', 123, { :rbx => 'cool', :specs => :fail_sometimes, :non_sym => 1234 }]
        )
      end

      it "passes without curly braces or parens" do
        expect(specs.fooM3 'abc', 123, rbx: 'cool', specs: :fail_sometimes, non_sym: 1234).to eq(
          ['abc', 123, { :rbx => 'cool', :specs => :fail_sometimes, :non_sym => 1234 }]
        )
      end

      it "handles a hanging comma without curly braces" do
        # specs.fooM3('abc', 123, abc: 123,).should == ['abc', 123, {:abc => 123}]
        # specs.fooM3('abc', 123, rbx: 'cool', specs: :fail_sometimes, non_sym: 1234,).should ==
          # ['abc', 123, { :rbx => 'cool', :specs => :fail_sometimes, :non_sym => 1234 }]
      end
    end
  end

  describe "mixed new- and old-style hash arguments" do
    describe "as the only parameter" do
      it "passes without curly braces" do
        expect(specs.fooM1(rbx: 'cool', :specs => :fail_sometimes, non_sym: 1234)).to eq(
          [{ :rbx => 'cool', :specs => :fail_sometimes, :non_sym => 1234 }]
        )
      end

      it "passes without curly braces or parens" do
        expect(specs.fooM1 :rbx => 'cool', specs: :fail_sometimes, non_sym: 1234).to eq(
          [{ :rbx => 'cool', :specs => :fail_sometimes, :non_sym => 1234 }]
        )
      end

      it "handles a hanging comma without curly braces" do
        # specs.fooM1(rbx: 'cool', specs: :fail_sometimes, :non_sym => 1234,).should ==
          # [{ :rbx => 'cool', :specs => :fail_sometimes, :non_sym => 1234 }]
      end
    end

    describe "as the last parameter" do
      it "passes without curly braces" do
        expect(specs.fooM3('abc', 123, rbx: 'cool', :specs => :fail_sometimes, non_sym: 1234)).to eq(
          ['abc', 123, { :rbx => 'cool', :specs => :fail_sometimes, :non_sym => 1234 }]
        )
      end

      it "passes without curly braces or parens" do
        expect(specs.fooM3 'abc', 123, :rbx => 'cool', specs: :fail_sometimes, non_sym: 1234).to eq(
          ['abc', 123, { :rbx => 'cool', :specs => :fail_sometimes, :non_sym => 1234 }]
        )
      end

      it "handles a hanging comma without curly braces" do
        # specs.fooM3('abc', 123, rbx: 'cool', specs: :fail_sometimes, :non_sym => 1234,).should ==
          # ['abc', 123, { :rbx => 'cool', :specs => :fail_sometimes, :non_sym => 1234 }]
      end
    end
  end

end
