describe "String#to_i" do
  it "returns 0 for strings with leading underscores" do
    "_123".to_i.should == 0
  end

  it "ignores subsequent invalid characters" do
    "123asdf".to_i.should == 123
    "123#123".to_i.should == 123
    "123 456".to_i.should == 123
  end

  it "interprets leading characters as a number in the given base" do
    "10110010010".to_i(2).should == 1426
    "100110201001".to_i(3).should == 186409
    "103110201001".to_i(4).should == 5064769
    "103110241001".to_i(5).should == 55165126
    "153110241001".to_i(6).should == 697341529
    "153160241001".to_i(7).should == 3521513430
    "153160241701".to_i(8).should == 14390739905
    "853160241701".to_i(9).should == 269716550518
    "853160241791".to_i(10).should == 853160241791

    "5e10".to_i.should == 5
  end
end