describe "Ruby numbers in various ways" do

  it "the standard way" do
    expect(435).to eq(435)
  end

  it "with underscore separations" do
    expect(4_35).to eq(435)
  end

  it "with some decimals" do
    expect(4.35).to eq(4.35)
  end

  it "with decimals but no integer part should be a SyntaxError" do
    expect { eval(".75")  }.to raise_error(SyntaxError)
    expect { eval("-.75") }.to raise_error(SyntaxError)
  end

  # TODO : find a better description
  it "using the e expression" do
    expect(1.2e-3).to eq(0.0012)
  end

  it "the hexdecimal notation" do
    expect(0xffff).to eq(65535)
  end

  it "the binary notation" do
    expect(0b01011).to eq(11)
    expect(0101).to eq(5)
    expect(001010).to eq(10)
    expect(0b1010).to eq(10)
    expect(0b10_10).to eq(10)
  end

  it "octal representation" do
    expect(0377).to eq(255)
    expect(0o377).to eq(255)
    expect(0o3_77).to eq(255)
  end

  ruby_version_is '' ... '1.9' do
    it "character to numeric shortcut" do
      expect(?z).to eq(122)
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
