require 'erb'
require File.expand_path('../simple', __FILE__)
require File.expand_path('../quoted', __FILE__)
require File.expand_path('../inline_block', __FILE__)
require File.expand_path('../with_locals', __FILE__)

describe "ERB files" do
  before :each do
    @simple = Template['opal/stdlib/erb/simple']
    @quoted = Template['opal/stdlib/erb/quoted']
    @inline_block = Template['opal/stdlib/erb/inline_block']
    @with_locals = Template['opal/stdlib/erb/with_locals']
  end

  it "should be defined by their filename on Template namespace" do
    @simple.should be_kind_of(Template)
  end

  it "calling the block with a context should render the block" do
    @some_data = "hello"
    @simple.render(self).should == "<div>hello</div>\n"
  end

  it "should accept quotes in strings" do
    @name = "adam"
    @quoted.render(self).should == "<div class=\"foo\">hello there adam</div>\n"
  end

  it "should be able to handle inline blocks" do
    @inline_block.should be_kind_of(Template)
  end

  describe 'template locals' do
    it 'can pass local variables to a template' do
      def self.non_local; 'Ford'; end
      @with_locals.render(self, :is_local => 'Perfect').should =~ /Ford\ Perfect/
    end
  end
end
