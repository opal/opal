require 'spec_helper'

describe 'String#each_char' do
  it 'passes each char in self to the given block' do
    a = []
    'hello'.each_char { |c| a << c }
    a.should == ['h', 'e', 'l', 'l', 'o']
  end

  it 'returns an enumerator when no block given' do
    enum = 'hello'.each_char
    enum.should be_an_instance_of(enumerator_class)
    enum.to_a.should == ['h', 'e', 'l', 'l', 'o']
  end

  it 'returns self' do
    s = 'hello'
    (s.each_char {}).should equal(s)
  end
end
