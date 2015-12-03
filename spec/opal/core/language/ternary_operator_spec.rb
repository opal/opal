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
end
