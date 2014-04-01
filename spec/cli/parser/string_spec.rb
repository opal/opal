require 'cli/spec_helper'

describe "Strings" do
  it "parses empty strings" do
    parsed('""').should == [:str, ""]
    parsed("''").should == [:str, ""]
  end

  it "parses a simple string without interpolation as s(:str)" do
    parsed('"foo # { } bar"').should == [:str, "foo # { } bar"]
  end

  it "does not interpolate with single quotes" do
    parsed("'\#{foo}'").should == [:str, "\#{foo}"]
    parsed("'\#@foo'").should == [:str, "\#@foo"]
    parsed("'\#$foo'").should == [:str, "\#$foo"]
    parsed("'\#@@foo'").should == [:str, "\#@@foo"]
  end

  it "supports interpolation with double quotes" do
    parsed('"#{foo}"').should == [:dstr, "", [:evstr, [:call, nil, :foo, [:arglist]]]]
    parsed('"#@foo"').should == [:dstr, "", [:evstr, [:ivar, :@foo]]]
    parsed('"#$foo"').should == [:dstr, "", [:evstr, [:gvar, :$foo]]]
    parsed('"#@@foo"').should == [:dstr, "", [:evstr, [:cvar, :@@foo]]]
  end

  it "allows underscores in ivar, gvar and cvar interpolation" do
    parsed('"#@foo_bar"').should == [:dstr, "", [:evstr, [:ivar, :@foo_bar]]]
    parsed('"#$foo_bar"').should == [:dstr, "", [:evstr, [:gvar, :$foo_bar]]]
    parsed('"#@@foo_bar"').should == [:dstr, "", [:evstr, [:cvar, :@@foo_bar]]]
  end

  describe "from %Q construction" do
    it "can use '[', '(', '{' or '<' matching pairs for string boundry" do
      parsed('%Q{foo}').should == [:str, "foo"]
      parsed('%Q[foo]').should == [:str, "foo"]
      parsed('%Q(foo)').should == [:str, "foo"]
      parsed('%Q<foo>').should == [:str, "foo"]
    end

    it "can use valid characters as string boundrys" do
      parsed('%q!Ford!').should == [:str, 'Ford']
      parsed('%qaForda').should == [:str, 'Ford']
      parsed('%q?Ford?').should == [:str, 'Ford']
    end

    it "can parse empty strings" do
      parsed('%Q{}').should == [:str, ""]
      parsed('%Q[]').should == [:str, ""]
      parsed('%Q()').should == [:str, ""]
    end

    it "should allow interpolation" do
      parsed('%Q(#{foo})').should == [:dstr, "", [:evstr, [:call, nil, :foo, [:arglist]]]]
      parsed('%Q[#{foo}]').should == [:dstr, "", [:evstr, [:call, nil, :foo, [:arglist]]]]
      parsed('%Q{#{foo}}').should == [:dstr, "", [:evstr, [:call, nil, :foo, [:arglist]]]]
    end

    it "should allow ivar, gvar and cvar interpolation" do
      parsed('%Q{#@foo}').should == [:dstr, "", [:evstr, [:ivar, :@foo]]]
      parsed('%Q{#$foo}').should == [:dstr, "", [:evstr, [:gvar, :$foo]]]
      parsed('%Q{#@@foo}').should == [:dstr, "", [:evstr, [:cvar, :@@foo]]]
    end

    it "should match '{' and '}' pairs used to start string before ending match" do
      parsed('%Q{{}}').should == [:str, "{}"]
      parsed('%Q{foo{bar}baz}').should == [:str, "foo{bar}baz"]
      parsed('%Q{{foo}bar}').should == [:str, "{foo}bar"]
      parsed('%Q{foo{bar}}').should == [:str, "foo{bar}"]
      parsed('%Q{foo#{bar}baz}').should == [:dstr, "foo", [:evstr, [:call, nil, :bar, [:arglist]]], [:str, "baz"]]
      parsed('%Q{a{b{c}d{e}f}g}').should == [:str, "a{b{c}d{e}f}g"]
      parsed('%Q{a{b{c}#{foo}d}e}').should == [:dstr, "a{b{c}", [:evstr, [:call, nil, :foo, [:arglist]]], [:str, "d}e"]]
    end

    it "should match '(' and ')' pairs used to start string before ending match" do
      parsed('%Q(())').should == [:str, "()"]
      parsed('%Q(foo(bar)baz)').should == [:str, "foo(bar)baz"]
      parsed('%Q((foo)bar)').should == [:str, "(foo)bar"]
      parsed('%Q(foo(bar))').should == [:str, "foo(bar)"]
      parsed('%Q(foo#{bar}baz)').should == [:dstr, "foo", [:evstr, [:call, nil, :bar, [:arglist]]], [:str, "baz"]]
      parsed('%Q(a(b(c)d(e)f)g)').should == [:str, "a(b(c)d(e)f)g"]
      parsed('%Q(a(b(c)#{foo}d)e)').should == [:dstr, "a(b(c)", [:evstr, [:call, nil, :foo, [:arglist]]], [:str, "d)e"]]
    end

    it "should match '[' and ']' pairs used to start string before ending match" do
      parsed('%Q[[]]').should == [:str, "[]"]
      parsed('%Q[foo[bar]baz]').should == [:str, "foo[bar]baz"]
      parsed('%Q[[foo]bar]').should == [:str, "[foo]bar"]
      parsed('%Q[foo[bar]]').should == [:str, "foo[bar]"]
      parsed('%Q[foo#{bar}baz]').should == [:dstr, "foo", [:evstr, [:call, nil, :bar, [:arglist]]], [:str, "baz"]]
      parsed('%Q[a[b[c]d[e]f]g]').should == [:str, "a[b[c]d[e]f]g"]
      parsed('%Q[a[b[c]#{foo}d]e]').should == [:dstr, "a[b[c]", [:evstr, [:call, nil, :foo, [:arglist]]], [:str, "d]e"]]
    end

    it "correctly parses block braces within interpolations" do
      parsed('%Q{#{each { nil } }}').should == [:dstr, "", [:evstr, [:call, nil, :each, [:arglist], [:iter, nil, [:nil]]]]]
    end

    it "parses other Qstrings within interpolations" do
      parsed('%Q{#{ %Q{} }}').should == [:dstr, "", [:evstr, [:str, ""]]]
    end
  end

  describe "from character shortcuts" do
    it "produces a string sexp" do
      parsed("?a").should == [:str, "a"]
      parsed("?&").should == [:str, "&"]
    end

    it "parses escape sequences" do
      parsed("?\\n").should == [:str, "\n"]
      parsed("?\\t").should == [:str, "\t"]
    end

    it "parses a string sexp as a command arg" do
      parsed("foo ?a").should == [:call, nil, :foo, [:arglist, [:str, "a"]]]
    end
  end

  it "parses %[] strings" do
    parsed('%[]').should == [:str, '']
    parsed('%[foo]').should == [:str, 'foo']
  end
end


describe "x-strings" do
  it "parses simple xstring as s(:xstr)" do
    parsed("`foo`").should == [:xstr, "foo"]
  end

  it "parses new lines within xstring" do
    parsed("`\nfoo\n\nbar`").should == [:xstr, "\nfoo\n\nbar"]
  end

  it "allows interpolation within xstring" do
    parsed('`#{bar}`').should == [:dxstr, "", [:evstr, [:call, nil, :bar, [:arglist]]]]
    parsed('`#{bar}#{baz}`').should == [:dxstr, "", [:evstr, [:call, nil, :bar, [:arglist]]], [:evstr, [:call, nil, :baz, [:arglist]]]]
  end

  it "supports ivar interpolation" do
    parsed('`#@foo`').should == [:dxstr, "", [:evstr, [:ivar, :@foo]]]
    parsed('`#@foo.bar`').should == [:dxstr, "", [:evstr, [:ivar, :@foo]], [:str, ".bar"]]
  end

  it "supports gvar interpolation" do
    parsed('`#$foo`').should == [:dxstr, "", [:evstr, [:gvar, :$foo]]]
    parsed('`#$foo.bar`').should == [:dxstr, "", [:evstr, [:gvar, :$foo]], [:str, ".bar"]]
  end

  it "supports cvar interpolation" do
    parsed('`#@@foo`').should == [:dxstr, "", [:evstr, [:cvar, :@@foo]]]
  end

  it "correctly parses block braces within interpolations" do
    parsed('`#{ each { nil } }`').should == [:dxstr, "", [:evstr, [:call, nil, :each, [:arglist], [:iter, nil, [:nil]]]]]
  end

  it "parses xstrings within interpolations" do
    parsed('`#{ `bar` }`').should == [:dxstr, "", [:evstr, [:xstr, "bar"]]]
  end

  it "parses multiple levels of interpolation" do
    parsed('`#{ `#{`bar`}` }`').should == [:dxstr, "", [:evstr, [:dxstr, "", [:evstr, [:xstr, "bar"]]]]]
  end

  describe "created using %x notation" do
    it "can use '[', '(' or '{' matching pairs for string boundry" do
      parsed('%x{foo}').should == [:xstr, "foo"]
      parsed('%x[foo]').should == [:xstr, "foo"]
      parsed('%x(foo)').should == [:xstr, "foo"]
    end

    it "can parse empty strings" do
      parsed('%x{}').should == [:xstr, ""]
      parsed('%x[]').should == [:xstr, ""]
      parsed('%x()').should == [:xstr, ""]
    end

    it "should allow interpolation" do
      parsed('%x{#{foo}}').should == [:dxstr, "", [:evstr, [:call, nil, :foo, [:arglist]]]]
      parsed('%x[#{foo}]').should == [:dxstr, "", [:evstr, [:call, nil, :foo, [:arglist]]]]
      parsed('%x(#{foo})').should == [:dxstr, "", [:evstr, [:call, nil, :foo, [:arglist]]]]
    end

    it "should allow ivar, gvar and cvar interpolation" do
      parsed('%x{#@foo}').should == [:dxstr, "", [:evstr, [:ivar, :@foo]]]
      parsed('%x{#$foo}').should == [:dxstr, "", [:evstr, [:gvar, :$foo]]]
      parsed('%x{#@@foo}').should == [:dxstr, "", [:evstr, [:cvar, :@@foo]]]
    end

    it "should match '{' and '}' pairs used to start string before ending match" do
      parsed('%x{{}}').should == [:xstr, "{}"]
      parsed('%x{foo{bar}baz}').should == [:xstr, "foo{bar}baz"]
      parsed('%x{{foo}bar}').should == [:xstr, "{foo}bar"]
      parsed('%x{foo{bar}}').should == [:xstr, "foo{bar}"]
      parsed('%x{foo#{bar}baz}').should == [:dxstr, "foo", [:evstr, [:call, nil, :bar, [:arglist]]], [:str, "baz"]]
      parsed('%x{a{b{c}d{e}f}g}').should == [:xstr, "a{b{c}d{e}f}g"]
      parsed('%x{a{b{c}#{foo}d}e}').should == [:dxstr, "a{b{c}", [:evstr, [:call, nil, :foo, [:arglist]]], [:str, "d}e"]]
    end

    it "should match '(' and ')' pairs used to start string before ending match" do
      parsed('%x(())').should == [:xstr, "()"]
      parsed('%x(foo(bar)baz)').should == [:xstr, "foo(bar)baz"]
      parsed('%x((foo)bar)').should == [:xstr, "(foo)bar"]
      parsed('%x(foo(bar))').should == [:xstr, "foo(bar)"]
      parsed('%x(foo#{bar}baz)').should == [:dxstr, "foo", [:evstr, [:call, nil, :bar, [:arglist]]], [:str, "baz"]]
      parsed('%x(a(b(c)d(e)f)g)').should == [:xstr, "a(b(c)d(e)f)g"]
      parsed('%x(a(b(c)#{foo}d)e)').should == [:dxstr, "a(b(c)", [:evstr, [:call, nil, :foo, [:arglist]]], [:str, "d)e"]]
    end

    it "should match '[' and ']' pairs used to start string before ending match" do
      parsed('%x[[]]').should == [:xstr, "[]"]
      parsed('%x[foo[bar]baz]').should == [:xstr, "foo[bar]baz"]
      parsed('%x[[foo]bar]').should == [:xstr, "[foo]bar"]
      parsed('%x[foo[bar]]').should == [:xstr, "foo[bar]"]
      parsed('%x[foo#{bar}baz]').should == [:dxstr, "foo", [:evstr, [:call, nil, :bar, [:arglist]]], [:str, "baz"]]
      parsed('%x[a[b[c]d[e]f]g]').should == [:xstr, "a[b[c]d[e]f]g"]
      parsed('%x[a[b[c]#{foo}d]e]').should == [:dxstr, "a[b[c]", [:evstr, [:call, nil, :foo, [:arglist]]], [:str, "d]e"]]
    end

    it "correctly parses block braces within interpolations" do
      parsed('%x{#{each { nil } }}').should == [:dxstr, "", [:evstr, [:call, nil, :each, [:arglist], [:iter, nil, [:nil]]]]]
    end

    it "parses other Xstrings within interpolations" do
      parsed('%x{#{ %x{} }}').should == [:dxstr, "", [:evstr, [:xstr, ""]]]
      parsed('%x{#{ `` }}').should == [:dxstr, "", [:evstr, [:xstr, ""]]]
      parsed('%x{#{ `foo` }}').should == [:dxstr, "", [:evstr, [:xstr, "foo"]]]
    end
  end

  describe "cannot be created with %X notation" do
    it "should not parse" do
      lambda {
        parsed('%X{}')
      }.should raise_error(Exception)
    end
  end
end

describe "Heredocs" do

  it "parses as a s(:str)" do
    parsed("a = <<-FOO\nbar\nFOO")[2].should == [:str, "bar\n"]
  end

  it "allows start marker to be wrapped in quotes" do
    parsed("a = <<-'FOO'\nbar\nFOO")[2].should == [:str, "bar\n"]
    parsed("a = <<-\"FOO\"\nbar\nFOO")[2].should == [:str, "bar\n"]
  end

  it "does not parse EOS unless beginning of line" do
    parsed("<<-FOO\ncontentFOO\nFOO").should == [:str, "contentFOO\n"]
  end

  it "does not parse EOS unless end of line" do
    parsed("<<-FOO\nsome FOO content\nFOO").should == [:str, "some FOO content\n"]
  end

  it "parses postfix code as if it appeared after heredoc" do
    parsed("<<-FOO.class\ncode\nFOO").should == [:call, [:str, "code\n"], :class, [:arglist]]
    parsed("bar(<<-FOO, 1, 2, 3)\ncode\nFOO").should == [:call, nil, :bar,
                                                              [:arglist, [:str, "code\n"],
                                                                         [:int, 1],
                                                                         [:int, 2],
                                                                         [:int, 3]]]
  end
end
