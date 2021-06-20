require 'spec_helper'

describe 'String#unpack' do
  it 'correctly unpacks with U* strings with latin-1 characters' do
    "café".unpack("U*").should == [99, 97, 102, 233]
  end

  it 'correctly unpacks with U* strings with latin-2 characters' do
    "pół".unpack("U*").should == [112, 243, 322]
  end
end
