describe Opal::Handlebars do
  before do
    @h = Opal::Handlebars.new
  end

  it "parses basic content" do
    @h.parse('hello').should == [:program, [[:content, 'hello']]]
  end

  it 'parses basic mustaches' do
    @h.parse('{{name}}').should == [:program, [[:mustache, [[:id, ['name']]], nil]]]
  end

  it 'parses mixtures of content and mustaches' do
    @h.parse('hello {{name}} friend').should == [:program, [[:content, 'hello '], [:mustache, [[:id, ['name']]], nil], [:content, ' friend']]]
  end

  it 'parses underscores in mustache ids' do
    @h.parse('{{user_name}}').should == [:program, [[:mustache, [[:id, ['user_name']]], nil]]]
  end

  it 'parses paths in mustaches' do
    @h.parse('{{user/name}}').should == [:program, [[:mustache, [[:id, ['user', 'name']]], nil]]]
    @h.parse('{{user.name}}').should == [:program, [[:mustache, [[:id, ['user', 'name']]], nil]]]
  end

  it 'parses mustaches with parameters' do
    @h.parse('{{foo bar}}').should == [:program, [[:mustache, [[:id, ['foo']], [:id, ['bar']]], nil]]]
  end

  it 'parses mustaches with string parameters' do
    @h.parse('{{foo "bar"}}').should == [:program, [[:mustache, [[:id, ['foo']], [:string, 'bar']], nil]]]
    @h.parse("{{foo 'baz'}}").should == [:program, [[:mustache, [[:id, ['foo']], [:string, 'baz']], nil]]]
  end

  it 'parses mustaches with integer parameters' do
    @h.parse('{{foo 42}}').should == [:program, [[:mustache, [[:id, ['foo']], [:integer, '42']], nil]]]
  end

  it 'parses comments' do
    @h.parse('{{! ignore this comments }}').should == [:program, [[:comment, ' ignore this comments ']]]
  end

  it 'parses mustaches with a hash argument' do
    @h.parse('{{foo bar=baz}}').should == [:program, [[:mustache, [[:id, ['foo']]], [:hash, [['bar', [:id, ['baz']]]]]]]]
    @h.parse('{{foo bar=baz woosh=kapow}}').should == [:program, [[:mustache, [[:id, ['foo']]], [:hash, [['bar', [:id, ['baz']]], ['woosh', [:id, ['kapow']]]]]]]]
  end
end