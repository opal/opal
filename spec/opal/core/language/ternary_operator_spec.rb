describe "Ternary condition operator" do
  it "returns the second argument if the condition is true" do
    (true ? 1 : 2).should == 1
  end

  it "returns the third argument if the condition is false" do
    (false ? 1 : 2).should == 2
  end

  it "doesn't get confused if : follows a string literal" do
    # this could be interpreted as a Ruby 1.9 symbol hash key
    (true ?'str':'another str').should == 'str'
  end

  it "doesn't interpret ?? as an identifier" do
    obj = mock("object with a query method")
    obj.should_receive("m?").and_return(true)
    (obj.m?? 1 : 2).should == 1
  end
end
