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
                                               [:paren, [:call, [:int, 1], :+, [:arglist, [:int, 2]]]],
                                               :+,
                                               [:arglist, [:paren, [:call, [:int, 3], :-, [:arglist, [:int, 4]]]]],
                                              ]
   opal_parse("(1 + 2) - (3 - 4)").should == [:call,
                                               [:paren, [:call, [:int, 1], :+, [:arglist, [:int, 2]]]],
                                               :-,
                                               [:arglist, [:paren, [:call, [:int, 3], :-, [:arglist, [:int, 4]]]]],
                                              ]
   opal_parse("(1 + 2) * (3 - 4)").should == [:call,
                                               [:paren, [:call, [:int, 1], :+, [:arglist, [:int, 2]]]],
                                               :*,
                                               [:arglist, [:paren, [:call, [:int, 3], :-, [:arglist, [:int, 4]]]]],
                                              ]
   opal_parse("(1 + 2) / (3 - 4)").should == [:call,
                                               [:paren, [:call, [:int, 1], :+, [:arglist, [:int, 2]]]],
                                               :/,
                                               [:arglist, [:paren, [:call, [:int, 3], :-, [:arglist, [:int, 4]]]]],
                                              ]
  end
end

describe "Calls with keywords as method names" do

  keywords = %w[class module defined? def undef end do if unless else elsif self true false
                nil __LINE__ __FILE__ begin rescue ensure case when or and not return next
                redo break super then while until yield alias]

  it "should correctly parse the keyword as a method name when after a '.'" do
    keywords.each do |kw|
      opal_parse("self.#{kw}").should == [:call, [:self], kw.to_sym, [:arglist]]
    end
  end
end

describe "Calls with operators as method names" do
  operators = %w[+ - * / & ** | ^ & <=> > >= < <= << >>]

  it "should correctly parse the operator as method name after '.'" do
    operators.each do |op|
      opal_parse("self.#{op}").should == [:call, [:self], op.to_sym, [:arglist]]
      opal_parse("self.#{op}(1)").should == [:call, [:self], op.to_sym, [:arglist, [:int, 1]]]
      opal_parse("self.#{op}(1, 2)").should == [:call, [:self], op.to_sym, [:arglist, [:int, 1], [:int, 2]]]
    end
  end
end

describe "Command calls with operators" do
  it "parses operators before \n in command calls" do
    [:<<, :>>, :|, :^, :&, :<=>, :==, :===, :=~, :>, :>=, :<, :<=, :<<, :>>, :%, :**].each do |mid|
      opal_parse("self #{mid}\nself").should == [:call, [:self], mid, [:arglist, [:self]]]
    end
  end
end
