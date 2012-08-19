describe "String#swapcase" do
  it "returns a new string with all uppercase chars from self converted to lowercase and vice versa" do
    "Hello".swapcase.should == "hELLO"
    "cYbEr_PuNk11".swapcase.should == "CyBeR_pUnK11"
    "+++---111222???".swapcase.should == "+++---111222???"
  end

  it "is locale insensitive (only upcases a-z and only downcases A-Z" do
    "ÄÖÜ".swapcase.should == "ÄÖÜ"
    "ärger".swapcase.should == "äRGER"
    "BÄR".swapcase.should == "bÄr"
  end

  it "returns subclass instances when called on a subclass" do
    StringSpecs::MyString.new("").swapcase.should be_kind_of(StringSpecs::MyString)
    StringSpecs::MyString.new("hello").swapcase.should be_kind_of(StringSpecs::MyString)
  end
end