describe "predefined global $~" do
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

describe "predefined global $:" do
  it "is initialized to an array of strings" do
    $:.is_a?(Array).should == true
  end
end

describe "predefined standard objects" do
  it "includes ARGF" do
    Object.const_defined?(:ARGF).should == true
  end

  it "includes ARGV" do
    Object.const_defined?(:ARGV).should == true
    ARGV.respond_to?(:[]).should == true
  end

  # already checked in spec_helper
  #it "includes a hash-like object ENV" do
  #  Object.const_defined?(:ENV).should == true
  #  ENV.respond_to?(:[]).should == true
  #end
end

describe "The predefined global constants" do
  it "includes TRUE" do
    Object.const_defined?(:TRUE).should == true
    TRUE.should be_true
  end

  it "includes FALSE" do
    Object.const_defined?(:FALSE).should == true
    FALSE.should be_false
  end

  it "includes NIL" do
    Object.const_defined?(:NIL).should == true
    NIL.should be_nil
  end

  it "includes STDIN" do
    Object.const_defined?(:STDIN).should == true
  end

  it "includes STDOUT" do
    Object.const_defined?(:STDOUT).should == true
  end

  it "includes STDERR" do
    Object.const_defined?(:STDERR).should == true
  end

  it "includes RUBY_VERSION" do
    Object.const_defined?(:RUBY_VERSION).should == true
    RUBY_VERSION.should == "2.1.1"
  end

  it "includes RUBY_RELEASE_DATE" do
    Object.const_defined?(:RUBY_RELEASE_DATE).should == true
  end

  it "includes RUBY_PLATFORM" do
    Object.const_defined?(:RUBY_PLATFORM).should == true
    RUBY_PLATFORM.should == "opal"
  end
end
