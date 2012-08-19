require 'spec_helper'

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
      opal_parse('%Q{#{each { nil } }}').should == [:dstr, "", [:evstr, [:iter, [:call, nil, :each, [:arglist]], nil, [:nil]]]]
    end

    it "parses other Qstrings within interpolations" do
      opal_parse('%Q{#{ %Q{} }}').should == [:dstr, "", [:evstr, [:str, ""]]]
    end
  end if false # FIXME
end
