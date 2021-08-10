require 'spec_helper'

describe 'Encoding' do
  it 'supports US-ASCII' do
    "è".encoding.name.should == 'UTF-8'
    "è".force_encoding('ASCII').should == "\xC3\xA8"
    "è".force_encoding('ascii').should == "\xC3\xA8"
    "è".force_encoding('US-ASCII').should == "\xC3\xA8"
    "è".force_encoding('us-ascii').should == "\xC3\xA8"
    "è".force_encoding('ASCII-8BIT').should == "\xC3\xA8"
    "è".force_encoding('ascii-8bit').should == "\xC3\xA8"
    "è".force_encoding('BINARY').should == "\xC3\xA8"
    "è".force_encoding('binary').should == "\xC3\xA8"
  end

  describe '.find' do
    it 'finds the encoding regardless of the case' do
      Encoding.find('ASCII').should == Encoding::ASCII
      Encoding.find('ascii').should == Encoding::ASCII
      Encoding.find('US-ASCII').should == Encoding::ASCII
      Encoding.find('us-ascii').should == Encoding::ASCII
      Encoding.find('ASCII-8BIT').should == Encoding::BINARY
      Encoding.find('ascii-8bit').should == Encoding::BINARY
      Encoding.find('BINARY').should == Encoding::BINARY
      Encoding.find('binary').should == Encoding::BINARY
    end
  end

  it 'is set only on a copy of the instance and not all strings' do
    # if the .encoding property is set in the wrong way in 'use strict' it will affect all strings
    a_string = 'è'
    a_string_encoding_before = a_string.encoding
    b_string = 'è'
    c_string = b_string.force_encoding('ASCII') # copy, which is different from ruby semantics
    a_string_encoding_after = a_string.encoding
    d_string = 'è'
    a_string_encoding_before.name.should == 'UTF-16LE'
    a_string_encoding_before.should == a_string_encoding_after
    c_string.encoding.should == Encoding::ASCII
    d_string.encoding.name.should == 'UTF-16LE'
  end
end
