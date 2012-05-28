describe "String#=~" do
  it "sets $~ to MatchData when there is a match and nil then there's none" do
    'hello' =~ /./
    $~[0].should == 'h'

    'hello' =~ /not/
    $~.should == nil
  end
end

describe "String#match" do
  it "matches the pattern against self" do
    'hello'.match(/(.)\1/)[0].should == "ll"
  end

  it "returns nil if there's no match" do
    'hello'.match('xx').should == nil
  end

  it "sets $~ to MatchData of match or nil when there is none" do
    'hello'.match(/./)
    $~[0].should == 'h'

    'hello'.match(/X/)
    $~.should == nil
  end
end