describe "Literal Regexps" do
  it "yields a Regexp" do
    /Hello/.should be_kind_of(Regexp)
  end
end

describe "Regexps with interpolation" do
  it "allows interpolation of strings" do
    str = "foo|bar"
    /#{str}/.should == /foo|bar/
  end

  it "allows interpolation to interact with other Regexp constructs" do
    str = "foo)|(bar"
    /(#{str})/.should == /(foo)|(bar)/

    str = "a"
    /[#{str}-z]/.should == /[a-z]/
  end
end