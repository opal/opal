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

  it "changes the value of derived capture globals when assigned" do
    "foo" =~ /(f)oo/
    foo_match = $~
    "bar" =~ /(b)ar/
    $~ = foo_match
    $1.should == "f"
  end
end

describe "Predefined global match $&" do
  it "is equivalent to MatchData#[0] on the last match $~" do
    /foo/ =~ 'barfoobaz'
    $&.should == $~[0]
    $&.should == 'foo'
  end
end
describe "Predefined global $`" do
  it "is equivalent to MatchData#pre_match on the last match $~" do
    /foo/ =~ 'barfoobaz'
    $`.should == $~.pre_match
    $`.should == 'bar'
  end
end

describe "Predefined global $'" do
  it "is equivalent to MatchData#post_match on the last match $~" do
    /foo/ =~ 'barfoobaz'
    $'.should == $~.post_match
    $'.should == 'baz'
  end
end

describe "predefined globals $1..N" do
  it "are equivalent to $~[N]" do
    /(f)(o)(o)/ =~ 'foo'
    $1.should == $~[1]
    $2.should == $~[2]
    $3.should == $~[3]
    $4.should == $~[4]

    [$1, $2, $3, $4].should == ['f', 'o', 'o', nil]
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

  it "includes RUBY_ENGINE" do
    Object.const_defined?(:RUBY_ENGINE).should == true
    RUBY_ENGINE.should == "opal"
  end

  it "includes RUBY_ENGINE_VERSION" do
    Object.const_defined?(:RUBY_ENGINE_VERSION).should == true
    RUBY_ENGINE_VERSION.should == Opal::VERSION
  end
end
