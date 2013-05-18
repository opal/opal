describe "StringScanner#get_byte" do
  before :each do
    @s = StringScanner.new("abc")
  end

  it "should return the next byte in string" do
    @s.get_byte.should == "a"
  end

  it "should set matched to next byte in string" do
    @s.matched.should be_nil
    @s.get_byte
    @s.matched.should == "a"
  end

  it "should advance position by 1" do
    @s.pos.should == 0
    @s.get_byte
    @s.pos.should == 1
  end

  it "should return nil if beyond end of string" do
    @s.get_byte.should == "a"
    @s.get_byte.should == "b"
    @s.get_byte.should == "c"
    @s.get_byte.should be_nil
    @s.matched.should be_nil
  end
end
