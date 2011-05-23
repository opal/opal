require File.expand_path('../../spec_helper', __FILE__)
# require File.expand_path('../../fixtures/class', __FILE__)

describe "self in a metaclass body (class << obj)" do
  it "is TrueClass for true" do
    class << true; self; end.should == TrueClass
  end

  it "is FalseClass for false" do
    class << false; self; end.should == FalseClass
  end

  it "is NilClass for nil" do
    class << nil; self; end.should == NilClass
  end

  it "raises a TypeError for numbers" do
    lambda { class << 1; self; end }.should raise_error(TypeError)
  end

  it "raises a TypeError for symbols" do
    lambda { class << :symbol; end }.should raise_error(TypeError)
  end
end

