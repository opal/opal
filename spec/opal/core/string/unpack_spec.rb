require 'spec_helper'

describe 'String#unpack' do
  it 'correctly unpacks with U* strings with latin-1 characters' do
    'café'.unpack('U*').should == [99, 97, 102, 233]
    [99, 97, 102, 233].pack('U*').unpack('U*').should == [99, 97, 102, 233]
  end

  it 'correctly unpacks with U* strings with latin-2 characters' do
    'pół'.unpack('U*').should == [112, 243, 322]
    [112, 243, 322].pack('U*').unpack('U*').should == [112, 243, 322]
  end

  it 'correctly unpacks with c* strings with latin-2 characters' do
    'ść'.unpack('c*').should == [-59, -101, -60, -121]
  end

  it 'correctly unpacks with s* binary strings' do
    "\xc8\x01".unpack('s*').should == [456]
    [678].pack('s').unpack('s').should == [678]
  end
end
