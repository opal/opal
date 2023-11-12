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
end

describe 'strip methods' do
  def strip_cases(before, after, method)
    before = before ? 1 : 0
    after = after ? 1 : 0

    it 'strip spaces' do
      "#{"  " * before}ABC#{"  " * after}".send(method).should == "ABC"
    end

    it 'strips NUL bytes' do
      "#{"\0" * before}ABC#{"\0" * after}".send(method).should == "ABC"
    end

    it "doesn't strip NBSPs" do
      "#{"\u{a0}" * before}ABC#{"\u{a0}" * after}".send(method).should != "ABC"
    end

    it "strips all other supported whitespace characters" do
      "#{"\r\n\t\v\f" * before}ABC#{"\r\n\t\v\f" * after}".send(method).should == "ABC"
    end
  end

  describe '#lstrip' do
   strip_cases true, false, :lstrip
  end

  describe '#rstrip' do
    strip_cases false, true, :rstrip
  end

  describe '#strip' do
    strip_cases true, true, :strip
  end
end
