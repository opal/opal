require 'spec_helper'

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
    opal_parse("foo 1").should == [:call, nil, :foo, [:arglist, [:int, 1]]]
    opal_parse("foo 1, 2").should == [:call, nil, :foo, [:arglist, [:int, 1], [:int, 2]]]
    opal_parse("foo 1, *2").should == [:call, nil, :foo, [:arglist, [:int, 1], [:splat, [:int, 2]]]]
  end

  it "supports leading dots on newline" do
    opal_parse("foo\n.bar").should == [:call, [:call, nil, :foo, [:arglist]], :bar, [:arglist]]
    lambda { opal_parse("foo\n..bar") }.should raise_error(Exception)
  end
end

describe "Operator calls" do
  it "should parse all other operators into method calls" do
    opal_parse("1 % 2").should == [:call, [:int, 1], :%, [:arglist, [:int, 2]]]
    opal_parse("1 ** 2").should == [:call, [:int, 1], :**, [:arglist, [:int, 2]]]

    opal_parse("+self").should == [:call, [:self], :+@, [:arglist]]
    opal_parse("-self").should == [:call, [:self], :-@, [:arglist]]

    opal_parse("1 | 2").should == [:call, [:int, 1], :|, [:arglist, [:int, 2]]]
    opal_parse("1 ^ 2").should == [:call, [:int, 1], :^, [:arglist, [:int, 2]]]
    opal_parse("1 & 2").should == [:call, [:int, 1], :&, [:arglist, [:int, 2]]]
    opal_parse("1 <=> 2").should == [:call, [:int, 1], :<=>, [:arglist, [:int, 2]]]

    opal_parse("1 < 2").should == [:call, [:int, 1], :<, [:arglist, [:int, 2]]]
    opal_parse("1 <= 2").should == [:call, [:int, 1], :<=, [:arglist, [:int, 2]]]
    opal_parse("1 > 2").should == [:call, [:int, 1], :>, [:arglist, [:int, 2]]]
    opal_parse("1 >= 2").should == [:call, [:int, 1], :>=, [:arglist, [:int, 2]]]

    opal_parse("1 == 2").should == [:call, [:int, 1], :==, [:arglist, [:int, 2]]]
    opal_parse("1 === 2").should == [:call, [:int, 1], :===, [:arglist, [:int, 2]]]
    opal_parse("1 =~ 2").should == [:call, [:int, 1], :=~, [:arglist, [:int, 2]]]

    opal_parse("~1").should == [:call, [:int, 1], :~, [:arglist]]
    opal_parse("1 << 2").should == [:call, [:int, 1], :<<, [:arglist, [:int, 2]]]
    opal_parse("1 >> 2").should == [:call, [:int, 1], :>>, [:arglist, [:int, 2]]]
  end

  it "optimizes +@ and -@ on numerics" do
    opal_parse("+1").should == [:int, 1]
    opal_parse("-1").should == [:int, -1]
  end
end

describe "Optional paren calls" do
  it "should correctly parse - and -@" do
    opal_parse("x - 1").should == [:call, [:call, nil, :x, [:arglist]], :-, [:arglist, [:int, 1]]]
    opal_parse("x -1").should == [:call, nil, :x, [:arglist, [:int, -1]]]
  end

  it "should correctly parse + and +@" do
    opal_parse("x + 1").should == [:call, [:call, nil, :x, [:arglist]], :+, [:arglist, [:int, 1]]]
    opal_parse("x +1").should == [:call, nil, :x, [:arglist, [:int, 1]]]
  end

  it "should correctly parse / and regexps" do
    opal_parse("x / 500").should == [:call, [:call, nil, :x, [:arglist]], :/, [:arglist, [:int, 500]]]
    opal_parse("x /foo/").should == [:call, nil, :x, [:arglist, [:regexp, /foo/]]]
  end

  it "should parse LPAREN_ARG correctly" do
    opal_parse("x (1).y").should == [:call, nil, :x, [:arglist, [:call, [:int, 1], :y, [:arglist]]]]
    opal_parse("x(1).y").should == [:call, [:call, nil, :x, [:arglist, [:int, 1]]], :y, [:arglist]]
  end
end

describe "Operator precedence" do
  it "should be raised with parentheses" do
   opal_parse("(1 + 2) + (3 - 4)").should == [:call,
                                               [:call, [:int, 1], :+, [:arglist, [:int, 2]]],
                                               :+,
                                               [:arglist, [:call, [:int, 3], :-, [:arglist, [:int, 4]]]],
                                              ]
   opal_parse("(1 + 2) - (3 - 4)").should == [:call,
                                               [:call, [:int, 1], :+, [:arglist, [:int, 2]]],
                                               :-,
                                               [:arglist, [:call, [:int, 3], :-, [:arglist, [:int, 4]]]],
                                              ]
   opal_parse("(1 + 2) * (3 - 4)").should == [:call,
                                               [:call, [:int, 1], :+, [:arglist, [:int, 2]]],
                                               :*,
                                               [:arglist, [:call, [:int, 3], :-, [:arglist, [:int, 4]]]],
                                              ]
   opal_parse("(1 + 2) / (3 - 4)").should == [:call,
                                               [:call, [:int, 1], :+, [:arglist, [:int, 2]]],
                                               :/,
                                               [:arglist, [:call, [:int, 3], :-, [:arglist, [:int, 4]]]],
                                              ]
  end
end
