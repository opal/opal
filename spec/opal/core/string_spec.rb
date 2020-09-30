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
      Encoding.find('ASCII-8BIT').should == Encoding::ASCII
      Encoding.find('ascii-8bit').should == Encoding::ASCII
      Encoding.find('BINARY').should == Encoding::ASCII
      Encoding.find('binary').should == Encoding::ASCII
    end
  end
end
