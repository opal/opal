require File.expand_path('../../spec_helper', __FILE__)

describe "Strings" do
  it "parses empty strings" do
    opal_parse('""').should == [:str, ""]
    opal_parse("''").should == [:str, ""]
  end

  it "parses a simple string without interpolation as s(:str)" do
    opal_parse('"foo # { } bar"').should == [:str, "foo # { } bar"]
  end

  it "does not interpolate with single quotes" do
    opal_parse("'\#{foo}'").should == [:str, "\#{foo}"]
    opal_parse("'\#@foo'").should == [:str, "\#@foo"]
    opal_parse("'\#$foo'").should == [:str, "\#$foo"]
    opal_parse("'\#@@foo'").should == [:str, "\#@@foo"]
  end

  it "supports interpolation with double quotes" do
    opal_parse('"#{foo}"').should == [:dstr, "", [:evstr, [:call, nil, :foo, [:arglist]]]]
    opal_parse('"#@foo"').should == [:dstr, "", [:evstr, [:ivar, :@foo]]]
    opal_parse('"#$foo"').should == [:dstr, "", [:evstr, [:gvar, :$foo]]]
    opal_parse('"#@@foo"').should == [:dstr, "", [:evstr, [:cvar, :@@foo]]]
  end

  it "allows underscores in ivar, gvar and cvar interpolation" do
    opal_parse('"#@foo_bar"').should == [:dstr, "", [:evstr, [:ivar, :@foo_bar]]]
    opal_parse('"#$foo_bar"').should == [:dstr, "", [:evstr, [:gvar, :$foo_bar]]]
    opal_parse('"#@@foo_bar"').should == [:dstr, "", [:evstr, [:cvar, :@@foo_bar]]]
  end

  describe "from %Q construction" do
    it "can use '[', '(' or '{' matching pairs for string boundry" do
      opal_parse('%Q{foo}').should == [:str, "foo"]
      opal_parse('%Q[foo]').should == [:str, "foo"]
      opal_parse('%Q(foo)').should == [:str, "foo"]
    end

    it "can parse empty strings" do
      opal_parse('%Q{}').should == [:str, ""]
      opal_parse('%Q[]').should == [:str, ""]
      opal_parse('%Q()').should == [:str, ""]
    end

    it "should allow interpolation" do
      opal_parse('%Q(#{foo})').should == [:dstr, "", [:evstr, [:call, nil, :foo, [:arglist]]]]
      opal_parse('%Q[#{foo}]').should == [:dstr, "", [:evstr, [:call, nil, :foo, [:arglist]]]]
      opal_parse('%Q{#{foo}}').should == [:dstr, "", [:evstr, [:call, nil, :foo, [:arglist]]]]
    end

    it "should allow ivar, gvar and cvar interpolation" do
      opal_parse('%Q{#@foo}').should == [:dstr, "", [:evstr, [:ivar, :@foo]]]
      opal_parse('%Q{#$foo}').should == [:dstr, "", [:evstr, [:gvar, :$foo]]]
      opal_parse('%Q{#@@foo}').should == [:dstr, "", [:evstr, [:cvar, :@@foo]]]
    end

    it "should match '{' and '}' pairs used to start string before ending match" do
      opal_parse('%Q{{}}').should == [:str, "{}"]
      opal_parse('%Q{foo{bar}baz}').should == [:str, "foo{bar}baz"]
      opal_parse('%Q{{foo}bar}').should == [:str, "{foo}bar"]
      opal_parse('%Q{foo{bar}}').should == [:str, "foo{bar}"]
      opal_parse('%Q{foo#{bar}baz}').should == [:dstr, "foo", [:evstr, [:call, nil, :bar, [:arglist]]], [:str, "baz"]]
      opal_parse('%Q{a{b{c}d{e}f}g}').should == [:str, "a{b{c}d{e}f}g"]
      opal_parse('%Q{a{b{c}#{foo}d}e}').should == [:dstr, "a{b{c}", [:evstr, [:call, nil, :foo, [:arglist]]], [:str, "d}e"]]
    end

    it "should match '(' and ')' pairs used to start string before ending match" do
      opal_parse('%Q(())').should == [:str, "()"]
      opal_parse('%Q(foo(bar)baz)').should == [:str, "foo(bar)baz"]
      opal_parse('%Q((foo)bar)').should == [:str, "(foo)bar"]
      opal_parse('%Q(foo(bar))').should == [:str, "foo(bar)"]
      opal_parse('%Q(foo#{bar}baz)').should == [:dstr, "foo", [:evstr, [:call, nil, :bar, [:arglist]]], [:str, "baz"]]
      opal_parse('%Q(a(b(c)d(e)f)g)').should == [:str, "a(b(c)d(e)f)g"]
      opal_parse('%Q(a(b(c)#{foo}d)e)').should == [:dstr, "a(b(c)", [:evstr, [:call, nil, :foo, [:arglist]]], [:str, "d)e"]]
    end

    it "should match '[' and ']' pairs used to start string before ending match" do
      opal_parse('%Q[[]]').should == [:str, "[]"]
      opal_parse('%Q[foo[bar]baz]').should == [:str, "foo[bar]baz"]
      opal_parse('%Q[[foo]bar]').should == [:str, "[foo]bar"]
      opal_parse('%Q[foo[bar]]').should == [:str, "foo[bar]"]
      opal_parse('%Q[foo#{bar}baz]').should == [:dstr, "foo", [:evstr, [:call, nil, :bar, [:arglist]]], [:str, "baz"]]
      opal_parse('%Q[a[b[c]d[e]f]g]').should == [:str, "a[b[c]d[e]f]g"]
      opal_parse('%Q[a[b[c]#{foo}d]e]').should == [:dstr, "a[b[c]", [:evstr, [:call, nil, :foo, [:arglist]]], [:str, "d]e"]]
    end

    it "correctly parses block braces within interpolations" do
      opal_parse('%Q{#{each { nil } }}').should == [:dstr, "", [:evstr, [:call, nil, :each, [:arglist], [:iter, nil, [:nil]]]]]
    end

    it "parses other Qstrings within interpolations" do
      opal_parse('%Q{#{ %Q{} }}').should == [:dstr, "", [:evstr, [:str, ""]]]
    end
  end

  describe "from character shortcuts" do
    it "produces a string sexp" do
      opal_parse("?a").should == [:str, "a"]
      opal_parse("?&").should == [:str, "&"]
    end

    it "parses a string sexp as a command arg" do
      opal_parse("foo ?a").should == [:call, nil, :foo, [:arglist, [:str, "a"]]]
    end
  end

  it "parses %[] strings" do
    opal_parse('%[]').should == [:str, '']
    opal_parse('%[foo]').should == [:str, 'foo']
  end
end


describe "x-strings" do
  it "parses simple xstring as s(:xstr)" do
    opal_parse("`foo`").should == [:xstr, "foo"]
  end

  it "parses new lines within xstring" do
    opal_parse("`\nfoo\n\nbar`").should == [:xstr, "\nfoo\n\nbar"]
  end

  it "allows interpolation within xstring" do
    opal_parse('`#{bar}`').should == [:dxstr, "", [:evstr, [:call, nil, :bar, [:arglist]]]]
    opal_parse('`#{bar}#{baz}`').should == [:dxstr, "", [:evstr, [:call, nil, :bar, [:arglist]]], [:evstr, [:call, nil, :baz, [:arglist]]]]
  end

  it "supports ivar interpolation" do
    opal_parse('`#@foo`').should == [:dxstr, "", [:evstr, [:ivar, :@foo]]]
    opal_parse('`#@foo.bar`').should == [:dxstr, "", [:evstr, [:ivar, :@foo]], [:str, ".bar"]]
  end

  it "supports gvar interpolation" do
    opal_parse('`#$foo`').should == [:dxstr, "", [:evstr, [:gvar, :$foo]]]
    opal_parse('`#$foo.bar`').should == [:dxstr, "", [:evstr, [:gvar, :$foo]], [:str, ".bar"]]
  end

  it "supports cvar interpolation" do
    opal_parse('`#@@foo`').should == [:dxstr, "", [:evstr, [:cvar, :@@foo]]]
  end

  it "correctly parses block braces within interpolations" do
    opal_parse('`#{ each { nil } }`').should == [:dxstr, "", [:evstr, [:call, nil, :each, [:arglist], [:iter, nil, [:nil]]]]]
  end

  it "parses xstrings within interpolations" do
    opal_parse('`#{ `bar` }`').should == [:dxstr, "", [:evstr, [:xstr, "bar"]]]
  end

  it "parses multiple levels of interpolation" do
    opal_parse('`#{ `#{`bar`}` }`').should == [:dxstr, "", [:evstr, [:dxstr, "", [:evstr, [:xstr, "bar"]]]]]
  end

  describe "created using %x notation" do
    it "can use '[', '(' or '{' matching pairs for string boundry" do
      opal_parse('%x{foo}').should == [:xstr, "foo"]
      opal_parse('%x[foo]').should == [:xstr, "foo"]
      opal_parse('%x(foo)').should == [:xstr, "foo"]
    end

    it "can parse empty strings" do
      opal_parse('%x{}').should == [:xstr, ""]
      opal_parse('%x[]').should == [:xstr, ""]
      opal_parse('%x()').should == [:xstr, ""]
    end

    it "should allow interpolation" do
      opal_parse('%x{#{foo}}').should == [:dxstr, "", [:evstr, [:call, nil, :foo, [:arglist]]]]
      opal_parse('%x[#{foo}]').should == [:dxstr, "", [:evstr, [:call, nil, :foo, [:arglist]]]]
      opal_parse('%x(#{foo})').should == [:dxstr, "", [:evstr, [:call, nil, :foo, [:arglist]]]]
    end

    it "should allow ivar, gvar and cvar interpolation" do
      opal_parse('%x{#@foo}').should == [:dxstr, "", [:evstr, [:ivar, :@foo]]]
      opal_parse('%x{#$foo}').should == [:dxstr, "", [:evstr, [:gvar, :$foo]]]
      opal_parse('%x{#@@foo}').should == [:dxstr, "", [:evstr, [:cvar, :@@foo]]]
    end

    it "should match '{' and '}' pairs used to start string before ending match" do
      opal_parse('%x{{}}').should == [:xstr, "{}"]
      opal_parse('%x{foo{bar}baz}').should == [:xstr, "foo{bar}baz"]
      opal_parse('%x{{foo}bar}').should == [:xstr, "{foo}bar"]
      opal_parse('%x{foo{bar}}').should == [:xstr, "foo{bar}"]
      opal_parse('%x{foo#{bar}baz}').should == [:dxstr, "foo", [:evstr, [:call, nil, :bar, [:arglist]]], [:str, "baz"]]
      opal_parse('%x{a{b{c}d{e}f}g}').should == [:xstr, "a{b{c}d{e}f}g"]
      opal_parse('%x{a{b{c}#{foo}d}e}').should == [:dxstr, "a{b{c}", [:evstr, [:call, nil, :foo, [:arglist]]], [:str, "d}e"]]
    end

    it "should match '(' and ')' pairs used to start string before ending match" do
      opal_parse('%x(())').should == [:xstr, "()"]
      opal_parse('%x(foo(bar)baz)').should == [:xstr, "foo(bar)baz"]
      opal_parse('%x((foo)bar)').should == [:xstr, "(foo)bar"]
      opal_parse('%x(foo(bar))').should == [:xstr, "foo(bar)"]
      opal_parse('%x(foo#{bar}baz)').should == [:dxstr, "foo", [:evstr, [:call, nil, :bar, [:arglist]]], [:str, "baz"]]
      opal_parse('%x(a(b(c)d(e)f)g)').should == [:xstr, "a(b(c)d(e)f)g"]
      opal_parse('%x(a(b(c)#{foo}d)e)').should == [:dxstr, "a(b(c)", [:evstr, [:call, nil, :foo, [:arglist]]], [:str, "d)e"]]
    end

    it "should match '[' and ']' pairs used to start string before ending match" do
      opal_parse('%x[[]]').should == [:xstr, "[]"]
      opal_parse('%x[foo[bar]baz]').should == [:xstr, "foo[bar]baz"]
      opal_parse('%x[[foo]bar]').should == [:xstr, "[foo]bar"]
      opal_parse('%x[foo[bar]]').should == [:xstr, "foo[bar]"]
      opal_parse('%x[foo#{bar}baz]').should == [:dxstr, "foo", [:evstr, [:call, nil, :bar, [:arglist]]], [:str, "baz"]]
      opal_parse('%x[a[b[c]d[e]f]g]').should == [:xstr, "a[b[c]d[e]f]g"]
      opal_parse('%x[a[b[c]#{foo}d]e]').should == [:dxstr, "a[b[c]", [:evstr, [:call, nil, :foo, [:arglist]]], [:str, "d]e"]]
    end

    it "correctly parses block braces within interpolations" do
      opal_parse('%x{#{each { nil } }}').should == [:dxstr, "", [:evstr, [:call, nil, :each, [:arglist], [:iter, nil, [:nil]]]]]
    end

    it "parses other Xstrings within interpolations" do
      opal_parse('%x{#{ %x{} }}').should == [:dxstr, "", [:evstr, [:xstr, ""]]]
      opal_parse('%x{#{ `` }}').should == [:dxstr, "", [:evstr, [:xstr, ""]]]
      opal_parse('%x{#{ `foo` }}').should == [:dxstr, "", [:evstr, [:xstr, "foo"]]]
    end
  end

  describe "cannot be created with %X notation" do
    it "should not parse" do
      lambda {
        opal_parse('%X{}')
      }.should raise_error(Exception)
    end
  end
end

describe "Heredocs" do

  it "parses as a s(:str)" do
    opal_parse("a = <<-FOO\nbar\nFOO")[2].should == [:str, "bar\n"]
  end

  it "allows start marker to be wrapped in quotes" do
    opal_parse("a = <<-'FOO'\nbar\nFOO")[2].should == [:str, "bar\n"]
    opal_parse("a = <<-\"FOO\"\nbar\nFOO")[2].should == [:str, "bar\n"]
  end

  it "does not parse EOS unless beginning of line" do
    opal_parse("<<-FOO\ncontentFOO\nFOO").should == [:str, "contentFOO\n"]
  end

  it "does not parse EOS unless end of line" do
    opal_parse("<<-FOO\nsome FOO content\nFOO").should == [:str, "some FOO content\n"]
  end

  it "parses postfix code as if it appeared after heredoc" do
    opal_parse("<<-FOO.class\ncode\nFOO").should == [:call, [:str, "code\n"], :class, [:arglist]]
    opal_parse("bar(<<-FOO, 1, 2, 3)\ncode\nFOO").should == [:call, nil, :bar,
                                                              [:arglist, [:str, "code\n"],
                                                                         [:int, 1],
                                                                         [:int, 2],
                                                                         [:int, 3]]]
  end
end
