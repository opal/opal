require File.expand_path('../../spec_helper', __FILE__)

class UndefSpecClass
  def meth(other);other;end
end

describe "The undef keyword" do
  it "undefines 'meth='" do
    obj = ::UndefSpecClass.new
    (obj.meth 5).should == 5
    class ::UndefSpecClass
      undef meth
    end
    lambda { obj.meth 5 }.should raise_error(NoMethodError)
  end
end
