require "spec_helper"

class BasicObjectSendSpec
  def foo
    :bar
  end

  def method_missing(symbol, *args, &block)
    "called_#{symbol}"
  end

  class Subclass < BasicObjectSendSpec
    def method_missing(symbol, *args, &block)
      args
    end
  end
end

describe "BasicObject#__send__"  do
  it "should call method_missing for undefined method" do
    BasicObjectSendSpec.new.__send__(:foo).should eq(:bar)
    BasicObjectSendSpec.new.__send__(:pow).should eq('called_pow')
  end

  it "should pass on arguments to method_missing" do
    BasicObjectSendSpec::Subclass.new.__send__(:blah, 1, 2, 3).should eq([1, 2, 3])
  end
end
