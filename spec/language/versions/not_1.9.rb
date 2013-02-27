describe "not()" do
  # not(arg).method and method(not(arg)) raise SyntaxErrors on 1.8. Here we
  # use #inspect to test that the syntax works on 1.9

  pending "can be used as a function" do
    lambda do
      not(true).inspect
    end.should_not raise_error(SyntaxError)
  end

  pending "returns false if the argument is true" do
    not(true).inspect.should == "false"
  end

  pending "returns true if the argument is false" do
    not(false).inspect.should == "true"
  end

  pending "returns true if the argument is nil" do
    not(false).inspect.should == "true"
  end
end
