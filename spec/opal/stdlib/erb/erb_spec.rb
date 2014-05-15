require 'erb'
require File.expand_path('../simple.opalerb', __FILE__)
require File.expand_path('../quoted.opalerb', __FILE__)
require File.expand_path('../inline_block.opalerb', __FILE__)

describe "ERB files" do
  before :each do
    @simple = Template['opal/stdlib/erb/simple']
    @quoted = Template['opal/stdlib/erb/quoted']
    @inline_block = Template['opal/stdlib/erb/inline_block']
  end

  it "should be defined by their filename on Template namespace" do
    expect(@simple).to be_kind_of(Template)
  end

  it "calling the block with a context should render the block" do
    @some_data = "hello"
    expect(@simple.render(self)).to eq("<div>hello</div>\n")
  end

  it "should accept quotes in strings" do
    @name = "adam"
    expect(@quoted.render(self)).to eq("<div class=\"foo\">hello there adam</div>\n")
  end

  it "should be able to handle inline blocks" do
    expect(@inline_block).to be_kind_of(Template)
  end
end
