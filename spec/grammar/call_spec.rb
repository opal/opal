require File.expand_path('../../spec_helper', __FILE__)

describe "Method calls" do
  it "should use 'nil' for calls without a receiver" do
    opal_parse("foo").should == [:call, nil, :foo, [:arglist]]
    opal_parse("foo()").should == [:call, nil, :foo, [:arglist]]
  end

  it "should always have an arglist when not passed any arguments" do
    opal_parse("foo").should == [:call, nil, :foo, [:arglist]]
    opal_parse("self.foo").should == [:call, [:self], :foo, [:arglist]]
    opal_parse("foo()").should == [:call, nil, :foo, [:arglist]]
    opal_parse("self.foo()").should == [:call, [:self], :foo, [:arglist]]
  end

  it "appends all arguments onto arglist" do
    opal_parse("foo 1").should == [:call, nil, :foo, [:arglist, [:lit, 1]]]
    opal_parse("foo 1, 2").should == [:call, nil, :foo, [:arglist, [:lit, 1], [:lit, 2]]]
    opal_parse("foo 1, *2").should == [:call, nil, :foo, [:arglist, [:lit, 1], [:splat, [:lit, 2]]]]
  end
end

describe "Operator calls" do
  it "should optimize math ops into operator calls" do
    opal_parse("1 + 2").should == [:operator, :+, [:lit, 1], [:lit, 2]]
    # opal_parse("1 - 2").should == [:operator, :-, [:lit, 1] [:lit, 2]]
    opal_parse("1 / 2").should == [:operator, :/, [:lit, 1], [:lit, 2]]
    opal_parse("1 * 2").should == [:operator, :*, [:lit, 1], [:lit, 2]]
  end

  it "should parse all other operators into method calls" do
    opal_parse("1 % 2").should == [:call, [:lit, 1], :%, [:arglist, [:lit, 2]]]
    opal_parse("1 ** 2").should == [:call, [:lit, 1], :**, [:arglist, [:lit, 2]]]

    opal_parse("+self").should == [:call, [:self], :+@, [:arglist]]
    opal_parse("-self").should == [:call, [:self], :-@, [:arglist]]

    opal_parse("1 | 2").should == [:call, [:lit, 1], :|, [:arglist, [:lit, 2]]]
    opal_parse("1 ^ 2").should == [:call, [:lit, 1], :^, [:arglist, [:lit, 2]]]
    opal_parse("1 & 2").should == [:call, [:lit, 1], :&, [:arglist, [:lit, 2]]]
    opal_parse("1 <=> 2").should == [:call, [:lit, 1], :<=>, [:arglist, [:lit, 2]]]

    opal_parse("1 < 2").should == [:call, [:lit, 1], :<, [:arglist, [:lit, 2]]]
    opal_parse("1 <= 2").should == [:call, [:lit, 1], :<=, [:arglist, [:lit, 2]]]
    opal_parse("1 > 2").should == [:call, [:lit, 1], :>, [:arglist, [:lit, 2]]]
    opal_parse("1 >= 2").should == [:call, [:lit, 1], :>=, [:arglist, [:lit, 2]]]

    opal_parse("1 == 2").should == [:call, [:lit, 1], :==, [:arglist, [:lit, 2]]]
    opal_parse("1 === 2").should == [:call, [:lit, 1], :===, [:arglist, [:lit, 2]]]
    opal_parse("1 =~ 2").should == [:call, [:lit, 1], :=~, [:arglist, [:lit, 2]]]

    opal_parse("~1").should == [:call, [:lit, 1], :~, [:arglist]]
    opal_parse("1 << 2").should == [:call, [:lit, 1], :<<, [:arglist, [:lit, 2]]]
    opal_parse("1 >> 2").should == [:call, [:lit, 1], :>>, [:arglist, [:lit, 2]]]
  end

  it "optimizes +@ and -@ on numerics" do
    opal_parse("+1").should == [:lit, 1]
    opal_parse("-1").should == [:lit, -1]
  end
end