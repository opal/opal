describe "Numeric#chr" do
  it "returns a string containing the ASCII character represented by self" do
    111.chr.should == 'o'
    112.chr.should == 'p'
    97.chr.should ==  'a'
    108.chr.should == 'l'
  end
end