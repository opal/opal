describe "predefined global $~" do
  it "is set to contain the MatchData object of the last match if successful" do
    md = /foo/.match 'foo'
    expect($~).to be_kind_of(MatchData)
    expect($~.object_id).to eq(md.object_id)

    /bar/ =~ 'bar'
    expect($~).to be_kind_of(MatchData)
    expect($~.object_id).not_to eq(md.object_id)
  end

  it "is set to nil if the last match was unsuccessful" do
    /foo/ =~ 'foo'
    expect($~.nil?).to eq(false)

    /foo/ =~ 'bar'
    expect($~.nil?).to eq(true)
  end
end

describe "predefined global $:" do
  it "is initialized to an array of strings" do
    expect($:.is_a?(Array)).to eq(true)
  end
end

describe "predefined standard objects" do
  it "includes ARGF" do
    expect(Object.const_defined?(:ARGF)).to eq(true)
  end

  it "includes ARGV" do
    expect(Object.const_defined?(:ARGV)).to eq(true)
    expect(ARGV.respond_to?(:[])).to eq(true)
  end

  # already checked in spec_helper
  #it "includes a hash-like object ENV" do
  #  Object.const_defined?(:ENV).should == true
  #  ENV.respond_to?(:[]).should == true
  #end
end

describe "The predefined global constants" do
  it "includes TRUE" do
    expect(Object.const_defined?(:TRUE)).to eq(true)
    expect(TRUE).to be_true
  end

  it "includes FALSE" do
    expect(Object.const_defined?(:FALSE)).to eq(true)
    expect(FALSE).to be_false
  end

  it "includes NIL" do
    expect(Object.const_defined?(:NIL)).to eq(true)
    expect(NIL).to be_nil
  end

  it "includes STDIN" do
    expect(Object.const_defined?(:STDIN)).to eq(true)
  end

  it "includes STDOUT" do
    expect(Object.const_defined?(:STDOUT)).to eq(true)
  end

  it "includes STDERR" do
    expect(Object.const_defined?(:STDERR)).to eq(true)
  end

  it "includes RUBY_VERSION" do
    expect(Object.const_defined?(:RUBY_VERSION)).to eq(true)
    expect(RUBY_VERSION).to eq("2.1.1")
  end

  it "includes RUBY_RELEASE_DATE" do
    expect(Object.const_defined?(:RUBY_RELEASE_DATE)).to eq(true)
  end

  it "includes RUBY_PLATFORM" do
    expect(Object.const_defined?(:RUBY_PLATFORM)).to eq(true)
    expect(RUBY_PLATFORM).to eq("opal")
  end
end
