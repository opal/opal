require 'spec_helper'

describe 'String#each_byte' do
  it 'passes each byte in self to the given block' do
    a = []
    'hello'.each_byte { |c| a << c }
    a.should == [104, 101, 108, 108, 111]
  end

  it 'returns an enumerator when no block given' do
    enum = 'hello'.each_byte
    enum.should be_an_instance_of(enumerator_class)
    enum.to_a.should == [104, 101, 108, 108, 111]
  end

  it 'returns self' do
    s = 'hello'
    (s.each_byte {}).should equal(s)
  end
end
