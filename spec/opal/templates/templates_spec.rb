describe 'Templates' do
  before do
    opal_eval(Opal::ERBParser.new.compile("<div><%= @some_data %></div>", "simple_test"))
    @simple = Templates['simple_test']

    opal_eval(Opal::ERBParser.new.compile('<div class="foo">hello <%= "there " + @name %></div>', "quoted_test"))
    @quoted = Templates['quoted_test']
  end

  it "should create an instance for each template by its basename" do
    @simple.should be_kind_of(Templates)
  end

  it "should execute the body and return the result as a string, with #result" do
    @some_data = "hello"
    @simple.render(self).should == "<div>hello</div>"
  end

  it "should accept quotes in strings" do
    @name = "adam"
    @quoted.render(self).should == "<div class=\"foo\">hello there adam</div>"
  end
end