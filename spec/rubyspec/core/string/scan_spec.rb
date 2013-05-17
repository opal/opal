describe "String#scan" do
  VOWELS_RE_NO_CAPTURE = /[aeiou]/
  VOWELS_RE_CAPTURE = /([aeiou])/
  it "should create one-dimensional array of matches if pattern has no capture groups" do
    result = "string-a-long".scan(VOWELS_RE_NO_CAPTURE)
    result.should be_kind_of(Array)
    result.size.should == 3
    result.should == ["i", "a", "o"]
  end

  it "should create two-dimensional array of matches if pattern has capture groups" do
    result = "string-a-long".scan(VOWELS_RE_CAPTURE)
    result.should be_kind_of(Array)
    result.size.should == 3
    result.should == [["i"], ["a"], ["o"]]
  end

  it "should set implicit match variables to final match when no block" do
    result = "string-a-long".scan(VOWELS_RE_CAPTURE)
    $~.should be_kind_of(MatchData)
    $~.size.should == 2
    $~[0].should == "o"
    $~[1].should == "o"
    $`.should == "string-a-l"
    $~.pre_match.should == "string-a-l"
    $'.should == "ng"
    $~.post_match == "ng"
    result.should == [["i"], ["a"], ["o"]]
  end

  it "should set implicit match variables for each iteration of block" do
    iterations = 0
    vals = {
      :match_data => [],
      :capture1 => [],
      :pre_match => [],
      :post_match => []
    }

    result = "string-a-long".scan(VOWELS_RE_CAPTURE) do |capture1|
      iterations += 1
      vals[:match_data] << $~
      vals[:capture1] << capture1
      vals[:pre_match] << $`
      vals[:post_match] << $'
    end

    iterations.should == 3
    vals[:capture1].should == ["i", "a", "o"]
    vals[:pre_match].should == ["str", "string-", "string-a-l"]
    vals[:post_match].should == ["ng-a-long", "-long", "ng"]
    vals[:match_data][0][0].should == "i"
    vals[:match_data][1][0].should == "a"
    vals[:match_data][2][0].should == "o"
    result.should == "string-a-long"
  end

  # this verifies that the lastIndex is reset before using the regexp
  it "should get same matches on consecutive runs" do
    re = Regexp.new('[aeiou]', 'g')
    results1 = 'hello'.scan(re)
    results2 = 'hello'.scan(re)
    results1.should == ["e", "o"]
    results2.should == results1
  end
end
