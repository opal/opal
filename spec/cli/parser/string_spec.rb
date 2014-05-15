require 'support/parser_helpers'

describe "Strings" do
  it "parses empty strings" do
    expect(parsed('""')).to eq([:str, ""])
    expect(parsed("''")).to eq([:str, ""])
  end

  it "parses a simple string without interpolation as s(:str)" do
    expect(parsed('"foo # { } bar"')).to eq([:str, "foo # { } bar"])
  end

  it "does not interpolate with single quotes" do
    expect(parsed("'\#{foo}'")).to eq([:str, "\#{foo}"])
    expect(parsed("'\#@foo'")).to eq([:str, "\#@foo"])
    expect(parsed("'\#$foo'")).to eq([:str, "\#$foo"])
    expect(parsed("'\#@@foo'")).to eq([:str, "\#@@foo"])
  end

  it "supports interpolation with double quotes" do
    expect(parsed('"#{foo}"')).to eq([:dstr, "", [:evstr, [:call, nil, :foo, [:arglist]]]])
    expect(parsed('"#@foo"')).to eq([:dstr, "", [:evstr, [:ivar, :@foo]]])
    expect(parsed('"#$foo"')).to eq([:dstr, "", [:evstr, [:gvar, :$foo]]])
    expect(parsed('"#@@foo"')).to eq([:dstr, "", [:evstr, [:cvar, :@@foo]]])
  end

  it "allows underscores in ivar, gvar and cvar interpolation" do
    expect(parsed('"#@foo_bar"')).to eq([:dstr, "", [:evstr, [:ivar, :@foo_bar]]])
    expect(parsed('"#$foo_bar"')).to eq([:dstr, "", [:evstr, [:gvar, :$foo_bar]]])
    expect(parsed('"#@@foo_bar"')).to eq([:dstr, "", [:evstr, [:cvar, :@@foo_bar]]])
  end

  describe "from %Q construction" do
    it "can use '[', '(', '{' or '<' matching pairs for string boundry" do
      expect(parsed('%Q{foo}')).to eq([:str, "foo"])
      expect(parsed('%Q[foo]')).to eq([:str, "foo"])
      expect(parsed('%Q(foo)')).to eq([:str, "foo"])
      expect(parsed('%Q<foo>')).to eq([:str, "foo"])
    end

    it "can use valid characters as string boundrys" do
      expect(parsed('%q!Ford!')).to eq([:str, 'Ford'])
      expect(parsed('%qaForda')).to eq([:str, 'Ford'])
      expect(parsed('%q?Ford?')).to eq([:str, 'Ford'])
    end

    it "can parse empty strings" do
      expect(parsed('%Q{}')).to eq([:str, ""])
      expect(parsed('%Q[]')).to eq([:str, ""])
      expect(parsed('%Q()')).to eq([:str, ""])
    end

    it "should allow interpolation" do
      expect(parsed('%Q(#{foo})')).to eq([:dstr, "", [:evstr, [:call, nil, :foo, [:arglist]]]])
      expect(parsed('%Q[#{foo}]')).to eq([:dstr, "", [:evstr, [:call, nil, :foo, [:arglist]]]])
      expect(parsed('%Q{#{foo}}')).to eq([:dstr, "", [:evstr, [:call, nil, :foo, [:arglist]]]])
    end

    it "should allow ivar, gvar and cvar interpolation" do
      expect(parsed('%Q{#@foo}')).to eq([:dstr, "", [:evstr, [:ivar, :@foo]]])
      expect(parsed('%Q{#$foo}')).to eq([:dstr, "", [:evstr, [:gvar, :$foo]]])
      expect(parsed('%Q{#@@foo}')).to eq([:dstr, "", [:evstr, [:cvar, :@@foo]]])
    end

    it "should match '{' and '}' pairs used to start string before ending match" do
      expect(parsed('%Q{{}}')).to eq([:str, "{}"])
      expect(parsed('%Q{foo{bar}baz}')).to eq([:str, "foo{bar}baz"])
      expect(parsed('%Q{{foo}bar}')).to eq([:str, "{foo}bar"])
      expect(parsed('%Q{foo{bar}}')).to eq([:str, "foo{bar}"])
      expect(parsed('%Q{foo#{bar}baz}')).to eq([:dstr, "foo", [:evstr, [:call, nil, :bar, [:arglist]]], [:str, "baz"]])
      expect(parsed('%Q{a{b{c}d{e}f}g}')).to eq([:str, "a{b{c}d{e}f}g"])
      expect(parsed('%Q{a{b{c}#{foo}d}e}')).to eq([:dstr, "a{b{c}", [:evstr, [:call, nil, :foo, [:arglist]]], [:str, "d}e"]])
    end

    it "should match '(' and ')' pairs used to start string before ending match" do
      expect(parsed('%Q(())')).to eq([:str, "()"])
      expect(parsed('%Q(foo(bar)baz)')).to eq([:str, "foo(bar)baz"])
      expect(parsed('%Q((foo)bar)')).to eq([:str, "(foo)bar"])
      expect(parsed('%Q(foo(bar))')).to eq([:str, "foo(bar)"])
      expect(parsed('%Q(foo#{bar}baz)')).to eq([:dstr, "foo", [:evstr, [:call, nil, :bar, [:arglist]]], [:str, "baz"]])
      expect(parsed('%Q(a(b(c)d(e)f)g)')).to eq([:str, "a(b(c)d(e)f)g"])
      expect(parsed('%Q(a(b(c)#{foo}d)e)')).to eq([:dstr, "a(b(c)", [:evstr, [:call, nil, :foo, [:arglist]]], [:str, "d)e"]])
    end

    it "should match '[' and ']' pairs used to start string before ending match" do
      expect(parsed('%Q[[]]')).to eq([:str, "[]"])
      expect(parsed('%Q[foo[bar]baz]')).to eq([:str, "foo[bar]baz"])
      expect(parsed('%Q[[foo]bar]')).to eq([:str, "[foo]bar"])
      expect(parsed('%Q[foo[bar]]')).to eq([:str, "foo[bar]"])
      expect(parsed('%Q[foo#{bar}baz]')).to eq([:dstr, "foo", [:evstr, [:call, nil, :bar, [:arglist]]], [:str, "baz"]])
      expect(parsed('%Q[a[b[c]d[e]f]g]')).to eq([:str, "a[b[c]d[e]f]g"])
      expect(parsed('%Q[a[b[c]#{foo}d]e]')).to eq([:dstr, "a[b[c]", [:evstr, [:call, nil, :foo, [:arglist]]], [:str, "d]e"]])
    end

    it "correctly parses block braces within interpolations" do
      expect(parsed('%Q{#{each { nil } }}')).to eq([:dstr, "", [:evstr, [:call, nil, :each, [:arglist], [:iter, nil, [:nil]]]]])
    end

    it "parses other Qstrings within interpolations" do
      expect(parsed('%Q{#{ %Q{} }}')).to eq([:dstr, "", [:evstr, [:str, ""]]])
    end
  end

  describe "from character shortcuts" do
    it "produces a string sexp" do
      expect(parsed("?a")).to eq([:str, "a"])
      expect(parsed("?&")).to eq([:str, "&"])
    end

    it "parses escape sequences" do
      expect(parsed("?\\n")).to eq([:str, "\n"])
      expect(parsed("?\\t")).to eq([:str, "\t"])
    end

    it "parses a string sexp as a command arg" do
      expect(parsed("foo ?a")).to eq([:call, nil, :foo, [:arglist, [:str, "a"]]])
    end
  end

  it "parses %[] strings" do
    expect(parsed('%[]')).to eq([:str, ''])
    expect(parsed('%[foo]')).to eq([:str, 'foo'])
  end
end


describe "x-strings" do
  it "parses simple xstring as s(:xstr)" do
    expect(parsed("`foo`")).to eq([:xstr, "foo"])
  end

  it "parses new lines within xstring" do
    expect(parsed("`\nfoo\n\nbar`")).to eq([:xstr, "\nfoo\n\nbar"])
  end

  it "allows interpolation within xstring" do
    expect(parsed('`#{bar}`')).to eq([:dxstr, "", [:evstr, [:call, nil, :bar, [:arglist]]]])
    expect(parsed('`#{bar}#{baz}`')).to eq([:dxstr, "", [:evstr, [:call, nil, :bar, [:arglist]]], [:evstr, [:call, nil, :baz, [:arglist]]]])
  end

  it "supports ivar interpolation" do
    expect(parsed('`#@foo`')).to eq([:dxstr, "", [:evstr, [:ivar, :@foo]]])
    expect(parsed('`#@foo.bar`')).to eq([:dxstr, "", [:evstr, [:ivar, :@foo]], [:str, ".bar"]])
  end

  it "supports gvar interpolation" do
    expect(parsed('`#$foo`')).to eq([:dxstr, "", [:evstr, [:gvar, :$foo]]])
    expect(parsed('`#$foo.bar`')).to eq([:dxstr, "", [:evstr, [:gvar, :$foo]], [:str, ".bar"]])
  end

  it "supports cvar interpolation" do
    expect(parsed('`#@@foo`')).to eq([:dxstr, "", [:evstr, [:cvar, :@@foo]]])
  end

  it "correctly parses block braces within interpolations" do
    expect(parsed('`#{ each { nil } }`')).to eq([:dxstr, "", [:evstr, [:call, nil, :each, [:arglist], [:iter, nil, [:nil]]]]])
  end

  it "parses xstrings within interpolations" do
    expect(parsed('`#{ `bar` }`')).to eq([:dxstr, "", [:evstr, [:xstr, "bar"]]])
  end

  it "parses multiple levels of interpolation" do
    expect(parsed('`#{ `#{`bar`}` }`')).to eq([:dxstr, "", [:evstr, [:dxstr, "", [:evstr, [:xstr, "bar"]]]]])
  end

  describe "created using %x notation" do
    it "can use '[', '(' or '{' matching pairs for string boundry" do
      expect(parsed('%x{foo}')).to eq([:xstr, "foo"])
      expect(parsed('%x[foo]')).to eq([:xstr, "foo"])
      expect(parsed('%x(foo)')).to eq([:xstr, "foo"])
    end

    it "can parse empty strings" do
      expect(parsed('%x{}')).to eq([:xstr, ""])
      expect(parsed('%x[]')).to eq([:xstr, ""])
      expect(parsed('%x()')).to eq([:xstr, ""])
    end

    it "should allow interpolation" do
      expect(parsed('%x{#{foo}}')).to eq([:dxstr, "", [:evstr, [:call, nil, :foo, [:arglist]]]])
      expect(parsed('%x[#{foo}]')).to eq([:dxstr, "", [:evstr, [:call, nil, :foo, [:arglist]]]])
      expect(parsed('%x(#{foo})')).to eq([:dxstr, "", [:evstr, [:call, nil, :foo, [:arglist]]]])
    end

    it "should allow ivar, gvar and cvar interpolation" do
      expect(parsed('%x{#@foo}')).to eq([:dxstr, "", [:evstr, [:ivar, :@foo]]])
      expect(parsed('%x{#$foo}')).to eq([:dxstr, "", [:evstr, [:gvar, :$foo]]])
      expect(parsed('%x{#@@foo}')).to eq([:dxstr, "", [:evstr, [:cvar, :@@foo]]])
    end

    it "should match '{' and '}' pairs used to start string before ending match" do
      expect(parsed('%x{{}}')).to eq([:xstr, "{}"])
      expect(parsed('%x{foo{bar}baz}')).to eq([:xstr, "foo{bar}baz"])
      expect(parsed('%x{{foo}bar}')).to eq([:xstr, "{foo}bar"])
      expect(parsed('%x{foo{bar}}')).to eq([:xstr, "foo{bar}"])
      expect(parsed('%x{foo#{bar}baz}')).to eq([:dxstr, "foo", [:evstr, [:call, nil, :bar, [:arglist]]], [:str, "baz"]])
      expect(parsed('%x{a{b{c}d{e}f}g}')).to eq([:xstr, "a{b{c}d{e}f}g"])
      expect(parsed('%x{a{b{c}#{foo}d}e}')).to eq([:dxstr, "a{b{c}", [:evstr, [:call, nil, :foo, [:arglist]]], [:str, "d}e"]])
    end

    it "should match '(' and ')' pairs used to start string before ending match" do
      expect(parsed('%x(())')).to eq([:xstr, "()"])
      expect(parsed('%x(foo(bar)baz)')).to eq([:xstr, "foo(bar)baz"])
      expect(parsed('%x((foo)bar)')).to eq([:xstr, "(foo)bar"])
      expect(parsed('%x(foo(bar))')).to eq([:xstr, "foo(bar)"])
      expect(parsed('%x(foo#{bar}baz)')).to eq([:dxstr, "foo", [:evstr, [:call, nil, :bar, [:arglist]]], [:str, "baz"]])
      expect(parsed('%x(a(b(c)d(e)f)g)')).to eq([:xstr, "a(b(c)d(e)f)g"])
      expect(parsed('%x(a(b(c)#{foo}d)e)')).to eq([:dxstr, "a(b(c)", [:evstr, [:call, nil, :foo, [:arglist]]], [:str, "d)e"]])
    end

    it "should match '[' and ']' pairs used to start string before ending match" do
      expect(parsed('%x[[]]')).to eq([:xstr, "[]"])
      expect(parsed('%x[foo[bar]baz]')).to eq([:xstr, "foo[bar]baz"])
      expect(parsed('%x[[foo]bar]')).to eq([:xstr, "[foo]bar"])
      expect(parsed('%x[foo[bar]]')).to eq([:xstr, "foo[bar]"])
      expect(parsed('%x[foo#{bar}baz]')).to eq([:dxstr, "foo", [:evstr, [:call, nil, :bar, [:arglist]]], [:str, "baz"]])
      expect(parsed('%x[a[b[c]d[e]f]g]')).to eq([:xstr, "a[b[c]d[e]f]g"])
      expect(parsed('%x[a[b[c]#{foo}d]e]')).to eq([:dxstr, "a[b[c]", [:evstr, [:call, nil, :foo, [:arglist]]], [:str, "d]e"]])
    end

    it "correctly parses block braces within interpolations" do
      expect(parsed('%x{#{each { nil } }}')).to eq([:dxstr, "", [:evstr, [:call, nil, :each, [:arglist], [:iter, nil, [:nil]]]]])
    end

    it "parses other Xstrings within interpolations" do
      expect(parsed('%x{#{ %x{} }}')).to eq([:dxstr, "", [:evstr, [:xstr, ""]]])
      expect(parsed('%x{#{ `` }}')).to eq([:dxstr, "", [:evstr, [:xstr, ""]]])
      expect(parsed('%x{#{ `foo` }}')).to eq([:dxstr, "", [:evstr, [:xstr, "foo"]]])
    end
  end

  describe "cannot be created with %X notation" do
    it "should not parse" do
      expect {
        parsed('%X{}')
      }.to raise_error(Exception)
    end
  end
end

describe "Heredocs" do

  it "parses as a s(:str)" do
    expect(parsed("a = <<-FOO\nbar\nFOO")[2]).to eq([:str, "bar\n"])
  end

  it "allows start marker to be wrapped in quotes" do
    expect(parsed("a = <<-'FOO'\nbar\nFOO")[2]).to eq([:str, "bar\n"])
    expect(parsed("a = <<-\"FOO\"\nbar\nFOO")[2]).to eq([:str, "bar\n"])
  end

  it "does not parse EOS unless beginning of line" do
    expect(parsed("<<-FOO\ncontentFOO\nFOO")).to eq([:str, "contentFOO\n"])
  end

  it "does not parse EOS unless end of line" do
    expect(parsed("<<-FOO\nsome FOO content\nFOO")).to eq([:str, "some FOO content\n"])
  end

  it "parses postfix code as if it appeared after heredoc" do
    expect(parsed("<<-FOO.class\ncode\nFOO")).to eq([:call, [:str, "code\n"], :class, [:arglist]])
    expect(parsed("bar(<<-FOO, 1, 2, 3)\ncode\nFOO")).to eq([:call, nil, :bar,
                                                              [:arglist, [:str, "code\n"],
                                                                         [:int, 1],
                                                                         [:int, 2],
                                                                         [:int, 3]]])
  end
end
