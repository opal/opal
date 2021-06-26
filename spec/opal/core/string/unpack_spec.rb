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
    # It should be: "\xc8\x01". I will try to work this out with
    # parser in the following patch.
    "\u00c8\u0001".encode("iso-8859-1").unpack('s*').should == [456]
    [678].pack('s').unpack('s').should == [678]
  end
end
