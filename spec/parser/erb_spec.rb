describe "Opal.parse_erb" do
  before do
    @simple = opal_eval_compiled(Opal.parse_erb("<div><%= @some_data %></div>", "simple_test"))
    @quoted = opal_eval_compiled(Opal.parse_erb('<div class="foo">hello <%= "there " + @name %></div>', "quoted_test"))
  end

  it "should be an instance of ERB" do
    @simple.should be_kind_of(ERB)
  end

  it "calling the block with a context should render the block" do
    @some_data = "hello"
    @simple.render(self).should == "<div>hello</div>"
  end

  it "should accept quotes in strings" do
    @name = "adam"
    @quoted.render(self).should == "<div class=\"foo\">hello there adam</div>"
  end

  it 'stores created templates in ERB[] by name' do
    ERB['simple_test'].should == @simple
    ERB['quoted_test'].should == @quoted
  end

  describe '.parse' do
    it 'parses erb content by running it through compiler' do
      opal_eval_compiled Opal.parse_erb("hi there", 'test_parse')
      ERB['test_parse'].should be_kind_of(ERB)
    end
  end
end
