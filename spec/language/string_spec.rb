describe "Ruby character strings" do
  it "are produced from character shortcuts" do
    ?z.should == 'z'
  end

  it "should parse string into %[]" do 
    %[foo].should == "foo"
    %|bar|.should == "bar"
    %'baz'.should == "baz"
  end
end