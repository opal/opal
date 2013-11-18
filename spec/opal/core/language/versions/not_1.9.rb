describe "not()" do
  # not(arg).method and method(not(arg)) raise SyntaxErrors on 1.8. Here we
  # use #inspect to test that the syntax works on 1.9

  it "can be used as a function" do
    lambda do
      not(true).inspect
    end.should_not raise_error(SyntaxError)
  end

  it "returns false if the argument is true" do
    not(true).inspect.should == "false"
  end

  it "returns true if the argument is false" do
    not(false).inspect.should == "true"
  end

  it "returns true if the argument is nil" do
    not(nil).inspect.should == "true"
  end
end