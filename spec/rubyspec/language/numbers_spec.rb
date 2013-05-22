require File.expand_path('../../spec_helper', __FILE__)

describe "Ruby numbers in various ways" do

  it "the standard way" do
    435.should == 435
  end

  it "with underscore separations" do
    4_35.should == 435
  end

  it "with some decimals" do
    4.35.should == 4.35
  end

  it "with decimals but no integer part should be a SyntaxError" do
    lambda { eval(".75")  }.should raise_error(SyntaxError)
    lambda { eval("-.75") }.should raise_error(SyntaxError)
  end

  # TODO : find a better description
  it "using the e expression" do
    1.2e-3.should == 0.0012
  end

  it "the hexdecimal notation" do
    0xffff.should == 65535
  end

  it "the binary notation" do
    0b01011.should == 11
    0101.should == 5
    001010.should == 10
    0b1010.should == 10
    0b10_10.should == 10
  end

  it "octal representation" do
    0377.should == 255
    0o377.should == 255
    0o3_77.should == 255
  end

  ruby_version_is '' ... '1.9' do
    it "character to numeric shortcut" do
      ?z.should == 122
    end

    it "character with control character to numeric shortcut" do
      # Control-Z
      #?\C-z.should == 26

      # Meta-Z
      #?\M-z.should == 250

      # Meta-Control-Z
      #?\M-\C-z.should == 154
    end
  end

end
