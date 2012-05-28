describe "String#intern" do
  it "returns the symbol corresponding to self" do
    "Koala".intern.should == :Koala
    'cat'.intern.should == :cat
    '@cat'.intern.should == :@cat
    'cat and dog'.intern.should == :"cat and dog"
    "abc=".intern.should == :abc=
  end
end