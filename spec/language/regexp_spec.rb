
describe "Regexp literals" do
  
  # ===========================================================================
  # = Back-refs                                                               =
  # ===========================================================================
  
  it "saves match data in the $~ pseudo-global variable" do
    "hello" =~ /l+/
    $~.to_a.should == ["ll"]
  end
  
  it "saves captures in numbered $[1-9] variables" do
    "1234567890" =~ /(1)(2)(3)(4)(5)(6)(7)(8)(9)(0)/
    $~.to_a.should == ["1234567890", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    $1.should == "1"
    $2.should == "2"
    $3.should == "3"
    $4.should == "4"
    $5.should == "5"
    $6.should == "6"
    $7.should == "7"
    $8.should == "8"
    $9.should == "9"
  end
end
