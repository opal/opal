require 'support/parser_helpers'

describe "Method calls" do
  it "should use 'nil' for calls without a receiver" do
    expect(parsed("foo")).to eq([:call, nil, :foo, [:arglist]])
    expect(parsed("foo()")).to eq([:call, nil, :foo, [:arglist]])
  end

  it "should always have an arglist when not passed any arguments" do
    expect(parsed("foo")).to eq([:call, nil, :foo, [:arglist]])
    expect(parsed("self.foo")).to eq([:call, [:self], :foo, [:arglist]])
    expect(parsed("foo()")).to eq([:call, nil, :foo, [:arglist]])
    expect(parsed("self.foo()")).to eq([:call, [:self], :foo, [:arglist]])
  end

  it "appends all arguments onto arglist" do
    expect(parsed("foo 1")).to eq([:call, nil, :foo, [:arglist, [:int, 1]]])
    expect(parsed("foo 1, 2")).to eq([:call, nil, :foo, [:arglist, [:int, 1], [:int, 2]]])
    expect(parsed("foo 1, *2")).to eq([:call, nil, :foo, [:arglist, [:int, 1], [:splat, [:int, 2]]]])
  end

  it "supports leading dots on newline" do
    expect(parsed("foo\n.bar")).to eq([:call, [:call, nil, :foo, [:arglist]], :bar, [:arglist]])
    expect { parsed("foo\n..bar") }.to raise_error(Exception)
  end
end

describe "Operator calls" do
  it "should parse all other operators into method calls" do
    expect(parsed("1 % 2")).to eq([:call, [:int, 1], :%, [:arglist, [:int, 2]]])
    expect(parsed("1 ** 2")).to eq([:call, [:int, 1], :**, [:arglist, [:int, 2]]])

    expect(parsed("+self")).to eq([:call, [:self], :+@, [:arglist]])
    expect(parsed("-self")).to eq([:call, [:self], :-@, [:arglist]])

    expect(parsed("1 | 2")).to eq([:call, [:int, 1], :|, [:arglist, [:int, 2]]])
    expect(parsed("1 ^ 2")).to eq([:call, [:int, 1], :^, [:arglist, [:int, 2]]])
    expect(parsed("1 & 2")).to eq([:call, [:int, 1], :&, [:arglist, [:int, 2]]])
    expect(parsed("1 <=> 2")).to eq([:call, [:int, 1], :<=>, [:arglist, [:int, 2]]])

    expect(parsed("1 < 2")).to eq([:call, [:int, 1], :<, [:arglist, [:int, 2]]])
    expect(parsed("1 <= 2")).to eq([:call, [:int, 1], :<=, [:arglist, [:int, 2]]])
    expect(parsed("1 > 2")).to eq([:call, [:int, 1], :>, [:arglist, [:int, 2]]])
    expect(parsed("1 >= 2")).to eq([:call, [:int, 1], :>=, [:arglist, [:int, 2]]])

    expect(parsed("1 == 2")).to eq([:call, [:int, 1], :==, [:arglist, [:int, 2]]])
    expect(parsed("1 === 2")).to eq([:call, [:int, 1], :===, [:arglist, [:int, 2]]])
    expect(parsed("1 =~ 2")).to eq([:call, [:int, 1], :=~, [:arglist, [:int, 2]]])

    expect(parsed("~1")).to eq([:call, [:int, 1], :~, [:arglist]])
    expect(parsed("1 << 2")).to eq([:call, [:int, 1], :<<, [:arglist, [:int, 2]]])
    expect(parsed("1 >> 2")).to eq([:call, [:int, 1], :>>, [:arglist, [:int, 2]]])
  end

  it "optimizes +@ and -@ on numerics" do
    expect(parsed("+1")).to eq([:int, 1])
    expect(parsed("-1")).to eq([:int, -1])
  end
end

describe "Optional paren calls" do
  it "should correctly parse - and -@" do
    expect(parsed("x - 1")).to eq([:call, [:call, nil, :x, [:arglist]], :-, [:arglist, [:int, 1]]])
    expect(parsed("x -1")).to eq([:call, nil, :x, [:arglist, [:int, -1]]])
  end

  it "should correctly parse + and +@" do
    expect(parsed("x + 1")).to eq([:call, [:call, nil, :x, [:arglist]], :+, [:arglist, [:int, 1]]])
    expect(parsed("x +1")).to eq([:call, nil, :x, [:arglist, [:int, 1]]])
  end

  it "should correctly parse / and regexps" do
    expect(parsed("x / 500")).to eq([:call, [:call, nil, :x, [:arglist]], :/, [:arglist, [:int, 500]]])
    expect(parsed("x /foo/")).to eq([:call, nil, :x, [:arglist, [:regexp, 'foo', nil]]])
  end

  it "should parse LPAREN_ARG correctly" do
    expect(parsed("x (1).y")).to eq([:call, nil, :x, [:arglist, [:call, [:int, 1], :y, [:arglist]]]])
    expect(parsed("x(1).y")).to eq([:call, [:call, nil, :x, [:arglist, [:int, 1]]], :y, [:arglist]])
  end
end

describe "Operator precedence" do
  it "should be raised with parentheses" do
   expect(parsed("(1 + 2) + (3 - 4)")).to eq([:call,
                                               [:paren, [:call, [:int, 1], :+, [:arglist, [:int, 2]]]],
                                               :+,
                                               [:arglist, [:paren, [:call, [:int, 3], :-, [:arglist, [:int, 4]]]]],
                                              ])
   expect(parsed("(1 + 2) - (3 - 4)")).to eq([:call,
                                               [:paren, [:call, [:int, 1], :+, [:arglist, [:int, 2]]]],
                                               :-,
                                               [:arglist, [:paren, [:call, [:int, 3], :-, [:arglist, [:int, 4]]]]],
                                              ])
   expect(parsed("(1 + 2) * (3 - 4)")).to eq([:call,
                                               [:paren, [:call, [:int, 1], :+, [:arglist, [:int, 2]]]],
                                               :*,
                                               [:arglist, [:paren, [:call, [:int, 3], :-, [:arglist, [:int, 4]]]]],
                                              ])
   expect(parsed("(1 + 2) / (3 - 4)")).to eq([:call,
                                               [:paren, [:call, [:int, 1], :+, [:arglist, [:int, 2]]]],
                                               :/,
                                               [:arglist, [:paren, [:call, [:int, 3], :-, [:arglist, [:int, 4]]]]],
                                              ])
  end
end

describe "Calls with keywords as method names" do

  keywords = %w[class module defined? def undef end do if unless else elsif self true false
                nil __LINE__ __FILE__ begin rescue ensure case when or and not return next
                redo break super then while until yield alias]

  it "should correctly parse the keyword as a method name when after a '.'" do
    keywords.each do |kw|
      expect(parsed("self.#{kw}")).to eq([:call, [:self], kw.to_sym, [:arglist]])
    end
  end
end

describe "Calls with operators as method names" do
  operators = %w[+ - * / & ** | ^ & <=> > >= < <= << >>]

  it "should correctly parse the operator as method name after '.'" do
    operators.each do |op|
      expect(parsed("self.#{op}")).to eq([:call, [:self], op.to_sym, [:arglist]])
      expect(parsed("self.#{op}(1)")).to eq([:call, [:self], op.to_sym, [:arglist, [:int, 1]]])
      expect(parsed("self.#{op}(1, 2)")).to eq([:call, [:self], op.to_sym, [:arglist, [:int, 1], [:int, 2]]])
    end
  end
end

describe "Command calls with operators" do
  it "parses operators before \n in command calls" do
    [:<<, :>>, :|, :^, :&, :<=>, :==, :===, :=~, :>, :>=, :<, :<=, :<<, :>>, :%, :**].each do |mid|
      expect(parsed("self #{mid}\nself")).to eq([:call, [:self], mid, [:arglist, [:self]]])
    end
  end
end
