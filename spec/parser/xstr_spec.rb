require 'spec_helper'

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
    opal_parse('`#{ each { nil } }`').should == [:dxstr, "", [:evstr, [:iter, [:call, nil, :each, [:arglist]], nil, [:nil]]]]
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
      opal_parse('%x{#{each { nil } }}').should == [:dxstr, "", [:evstr, [:iter, [:call, nil, :each, [:arglist]], nil, [:nil]]]]
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
