require 'erb'

# Our 3 templates we use (we can require them as normal files)
require 'simple_erb_template'
require 'templates/prefixed'
require 'templates/foo/bar'

describe "Opal ERB files" do
  it "should be defined by their filename on Template namespace" do
    Template['simple_erb_template'].should be_kind_of(ERB)
  end

  it "should remove 'templates/' path prefix" do
    Template['templates/prefixed'].should be_nil
    Template['prefixed'].should be_kind_of(ERB)
  end

  it "should maintain '/' in template paths" do
    Template['foo/bar'].should be_kind_of(ERB)
  end

  it "calling the block with a context should render the block" do
    @some_data = "hello"
    Template['simple_erb_template'].render(self).should == "<div>hello</div>\n"
  end

  it "should accept quotes in strings" do
    @name = "adam"
    Template['foo/bar'].render(self).should == "<div class=\"foo\">hello there adam</div>\n"
  end
end
