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

describe 'undef with dynamic symbol (regression for https://github.com/opal/opal/pull/1128)' do
  class UndefWithDynamicSymbol1
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
