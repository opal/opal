require 'spec_helper'

describe "begin & rescue blocks" do
  it "should evaluate to begin blocks last expression when no exception" do
    result = begin
      "a"
    rescue
      "b"
    end

    result.should == "a"
  end

  it "should evaluate to rescue blocks last expression when exception" do
    result = begin
      raise "foo"
    rescue
      "bar"
    end

    result.should == "bar"
  end
end

describe "generated method names" do
  it "does not conflict with local Ruby variables" do
    Class.new {
      value = 123
      def value
        456
      end
      value.should == 123
    }
  end

  it "does not conflict with local JS variables" do
    Class.new {
      `var value = 123;`
      def value
        456
      end
      `value`.should == 123
    }
  end
end

describe 'undef with dynamic symbol (regression for https://github.com/opal/opal/pull/1128)' do
  class UndefWithDynamicSymbol
    def foo_bar
    end
  end

  class UndefWithDynamicSymbol
    bar = "bar"
    undef :"foo_#{bar}"
  end

  it 'should work' do
    lambda { UndefWithDynamicSymbol.new.foo_bar }.should raise_error(NoMethodError)
  end
end
