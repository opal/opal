describe "String#chomp with separator" do
  it "returns a new string with the given record separator removed" do
    "hello".chomp("llo").should == "he"
    "hellollo".chomp("llo").should == "hello"
  end

  it "removes carriage return (except \\r) chars multiple times when separator is an empty string" do
    "".chomp("").should == ""
    "hello".chomp("").should == "hello"
    "hello\n".chomp("").should == "hello"
    "hello\nx".chomp("").should == "hello\nx"
    "hello\r\n".chomp("").should == "hello"
    "hello\r\n\r\n\n\n\r\n".chomp("").should == "hello"

    "hello\r".chomp("").should == "hello\r"
    "hello\n\r".chomp("").should == "hello\n\r"
    "hello\r\r\r\n".chomp("").should == "hello\r\r"
  end

  it "removes carriage return chars(\\n, \\r, \\r\\n) when separator is \\n" do
    "hello".chomp("\n").should == "hello"
    "hello\n".chomp("\n").should == "hello"
    "hello\r\n".chomp("\n").should == "hello"
    "hello\n\r".chomp("\n").should == "hello\n"
    "hello\r".chomp("\n").should == "hello"
    "hello \n there".chomp("\n").should == "hello \n there"
    "hello\r\n\r\n\n\n\r\n".chomp("\n").should == "hello\r\n\r\n\n\n"

    "hello\n\r".chomp("\r").should == "hello\n"
    "hello\n\r\n".chomp("\r\n").should == "hello\n"
  end

  it "returns self if the separator is nil" do
    "hello\n\n".chomp(nil).should == "hello\n\n"
  end

  it "returns an empty string when called on an empty string" do
    "".chomp("\n").should == ""
    "".chomp("\r").should == ""
    "".chomp("").should == ""
    "".chomp(nil).should == ""
  end
end