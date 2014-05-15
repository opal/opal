describe "Literal Regexps" do
  it "yields a Regexp" do
    expect(/Hello/).to be_kind_of(Regexp)
  end
end

describe "Regexps with interpolation" do
  it "allows interpolation of strings" do
    str = "foo|bar"
    expect(/#{str}/).to eq(/foo|bar/)
  end

  it "allows interpolation to interact with other Regexp constructs" do
    str = "foo)|(bar"
    expect(/(#{str})/).to eq(/(foo)|(bar)/)

    str = "a"
    expect(/[#{str}-z]/).to eq(/[a-z]/)
  end
end