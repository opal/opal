require 'spec_helper'

describe "String" do
  it "handles contiguous parts correctly" do
    str = "a" "b"
    str.should == "ab"

    str2 = "d" "#{str}"
    str2.should == "dab"
  end

  it 'parses complex heredoc (pr #1363)' do
    str = <<'...end ruby23.y/module_eval...'

  def version
    23
  end

  def default_encoding
    Encoding::UTF_8
  end
...end ruby23.y/module_eval...

    str.should == "\n  def version\n    23\n  end\n\n  def default_encoding\n    Encoding::UTF_8\n  end\n"
  end
end

describe "String#tr" do
  it 'regression for: https://github.com/opal/opal/issues/1386' do
    'YWE/'.tr('+/', '-_').should == 'YWE_'
  end
end

describe 'Encoding' do
  it 'supports US-ASCII' do
    # this wouldn't be allowed under MRI:
    #   ruby -e "# encoding: utf-16le\np 'asdf'.force_encoding 'ascii'"                                                          ~/C/opal
    #   -e:1: UTF-16LE is not ASCII compatible (ArgumentError)
    # although for now seems to be the best way to handle it.
    "è".encoding.name.should == 'UTF-16LE'
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
