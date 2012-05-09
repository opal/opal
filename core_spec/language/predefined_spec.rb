describe "Predefined global $~" do
  it "is set to contain the MatchData object of the last match if successful" do
    md = /foo/.match 'foo'
    $~.should be_kind_of(MatchData)
    $~.object_id.should == md.object_id

    /bar/ =~ 'bar'
    $~.should be_kind_of(MatchData)
    $~.object_id.should_not == md.object_id
  end

  it "is set to nil if the last match was unsuccessful" do
    /foo/ =~ 'foo'
    $~.nil?.should == false

    /foo/ =~ 'bar'
    $~.nil?.should == true
  end
end