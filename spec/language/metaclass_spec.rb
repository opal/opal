describe "self in a metaclass body (class << obj)" do
  it "is Boolean for true" do
    class << true; self; end.should == Boolean
  end

  it "is Boolean for false" do
    class << false; self; end.should == Boolean
  end

  it "is NilClass for nil" do
    class << nil; self; end.should == NilClass
  end
end