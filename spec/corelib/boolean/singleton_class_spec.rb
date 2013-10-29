describe "A singleton class" do
  it "is Boolean for true" do
    true.singleton_class.should == Boolean
  end

  it "is Boolean for false" do
    false.singleton_class.should == Boolean
  end
end