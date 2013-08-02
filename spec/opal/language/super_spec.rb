require 'spec_helper'

class SingletonMethodSuperSpec
  def meth
    "bar"
  end
end

# FIXME: we cant make a better test case than this??? For some reason, a single test cannot be deduced
describe "The 'super' keyword" do
  it "passes the right arguments when a variable rewrites special `arguments` js object" do
    Struct.new(:a, :b, :c).new(1, 2, 3).b.should == 2
  end

  it "calls super method on object that defines singleton method calling super" do
    obj = SingletonMethodSuperSpec.new
    def obj.meth; "foo " + super; end
    obj.meth.should == "foo bar"
  end
end
