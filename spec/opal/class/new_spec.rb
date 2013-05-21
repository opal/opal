require 'spec_helper'


%x{
  function JavascriptClass(a, b, c) {
    this.bar = "foo";
    this.args = [a, b, c];
  }
}

describe "Class#new" do
  before do
    @js_class = `JavascriptClass`
  end

  it "returns a new instance of a class" do
    Object.new.class.should == Object
  end

  it "can create new instances of native javascript classes" do
    @js_class.new.bar.should == "foo"
  end

  it "passed in arguments to native class constructor" do
    @js_class.new(1, 2, 3).args.should == [1, 2, 3]
  end
end
