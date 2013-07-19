require 'erb'

require File.expand_path('../simple', __FILE__)
require File.expand_path('../quoted', __FILE__)

describe "ERB files" do
  before :each do
    @simple = ERB['opal/erb/simple']
    @quoted = ERB['opal/erb/quoted']
  end

  it "should be defined by their filename on ERB namespace" do
    @simple.should be_kind_of(ERB)
  end

  it "calling the block with a context should render the block" do
    @some_data = "hello"
    @simple.render(self).should == "<div>hello</div>\n"
  end

  it "should accept quotes in strings" do
    @name = "adam"
    @quoted.render(self).should == "<div class=\"foo\">hello there adam</div>\n"
  end
end
