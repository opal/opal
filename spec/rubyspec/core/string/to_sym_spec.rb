describe "String#to_sym" do
  it "returns the symbol corresponding to self" do
    "Koala".to_sym.should == :Koala
    'cat'.to_sym.should == :cat
    '@cat'.to_sym.should == :@cat
    'cat and dog'.to_sym.should == :"cat and dog"
    "abc=".to_sym.should == :abc=
  end
end