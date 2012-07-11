class MethodMissingSpec
  def method_missing(method, *args)
    [method, args]
  end
end

describe "method_missing" do
  before do
    @object = MethodMissingSpec.new
  end

  it "should be called for all missing methods" do
    @object.foo.should == ['foo', []]
    @object.bar(10).should == ['bar', [10]]
    (@object.title = 100).should == ['title=', [100]]
  end
end