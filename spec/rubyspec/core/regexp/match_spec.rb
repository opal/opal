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

  it "returns a MatchData object that exposes pre_match and post_match strings for inline regexp" do
    re = /note: /i
    result = re.match('preamble NOTE: This is just a test.')
    result.pre_match.should == 'preamble '
    result.post_match.should == 'This is just a test.'
  end

  it "returns a MatchData object that exposes pre_match and post_match strings for constructed regexp" do
    re = Regexp.new(/note: /i)
    result = re.match('preamble NOTE: This is just a test.')
    result.pre_match.should == 'preamble '
    result.post_match.should == 'This is just a test.'
  end

  it "sets $` and $' variables on match" do
    re = /note: /i
    re.match('preamble NOTE: This is just a test.')
    $`.should == 'preamble '
    $'.should == 'This is just a test.'
  end

  it "resets $` and $' when no match" do
    re = /note: /i
    re.match('preamble NOTE: This is just a test.')
    $`.should_not be_nil
    $'.should_not be_nil
    re.match(nil)
    $`.should be_nil
    $'.should be_nil
  end

  it "returns a MatchData object that exposes match array" do
    re = /(note): (.*)/i
    result = re.match('preamble NOTE: This is just a test.')
    result.length.should == 3
    result.size.should == 3
    result.captures.should == ['NOTE', 'This is just a test.']
    result.to_a.should == ['NOTE: This is just a test.', 'NOTE', 'This is just a test.']
    result[1].should == ['NOTE']
    result.values_at(1, -1).should == ['NOTE', 'This is just a test.']
    result.values_at(-3, 0).should == [nil, 'NOTE: This is just a test.']
  end

  it "replaces undefined with nil in match array" do
    re = /(a(b)c)?(def)/
    result = re.match("def")
    result.to_a.size.should == 4
    result.to_a.should == ["def", nil, nil, "def"]
  end

  it "returns a MatchData object that exposes regexp and string" do
    re = /(note): (.*)/i
    result = re.match('preamble NOTE: This is just a test.')
    result.string.should == 'preamble NOTE: This is just a test.'
    result.regexp.should == re
  end

  it "returns a MatchData object that provides access to offset of 0th element only" do
    re = /(note): (.*)/i
    result = re.match('preamble NOTE: This is just a test.')
    result.begin(0).should == 9
    result.begin(1).should == 9
    lambda { result.begin(2) }.should raise_error(ArgumentError)
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
