require 'spec_helper'

describe 'String#to_sym' do
  it 'returns a string literal' do
    str = "string"
    sym = str.to_sym
    `typeof(sym)`.should == 'string'
  end
end
