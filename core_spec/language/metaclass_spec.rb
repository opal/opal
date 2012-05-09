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
end