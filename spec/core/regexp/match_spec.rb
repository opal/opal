describe "Regexp#=~ on a successful match" do
  it "returns the index of the first character of the matching region" do
    (/(.)(.)(.)/ =~ "abc").should == 0
  end
end

describe "Regexp#match on a successful match" do
  it "returns a MatchData object" do
    /(.)(.)(.)/.match("abc").should be_kind_of(MatchData)
  end

  it "resets $~ if passed nil" do
    # set $~
    /./.match("a")
    $~.should be_kind_of(MatchData)

    /1/.match(nil)
    $~.should be_nil
  end
end

describe :regexp_match do
  it "returns nil if there is no match" do
    /xyz/.match("abxyc").should be_nil
  end

  it "returns nil if the object is nil" do
    /xyz/.match(nil).should be_nil
  end
end