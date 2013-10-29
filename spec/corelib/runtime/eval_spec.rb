describe "Opal.eval()" do
  it "evaluates ruby code by compiling it to javascript and running" do
    `Opal.eval("'foo'.class")`.should == String
  end
end
