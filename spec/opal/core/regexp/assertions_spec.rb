describe 'Regexp assertions' do
  it 'matches the beginning of input' do
    /\Atext/.should =~ 'text'
    /\Atext/.should_not =~ 'the text'

    regexp = Regexp.new('\Atext')
    regexp.should =~ 'text'
    regexp.should_not =~ 'the text'
  end

  it 'matches the end of input' do
    /text\z/.should =~ 'the text'
    /text\z/.should_not =~ 'text of'

    regexp = Regexp.new('text\z')
    regexp.should =~ 'the text'
    regexp.should_not =~ 'text of'
  end
end
