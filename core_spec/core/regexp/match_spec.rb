require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../shared/match', __FILE__)

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
