describe "StringScanner#skip" do
  before :each do
    @s = StringScanner.new("This is a test")
  end

  it "returns the number of characters skipped when matched" do
    @s.skip(/This/).should == 4
  end

  it "matches strictly at position" do
    @s.skip(/This/)
    @s.skip(/is/).should be_nil
  end

  it "returns nil when not matched" do
    @s.skip(/foo/).should be_nil
  end

  it "advances the scan pointer when matched" do
    @s.skip(/This/)
    @s.pos.should == 4
  end

  it "does not advance the scan pointer when not matched" do
    @s.skip(/foo/)
    @s.pos.should == 0
  end

  it "captures the matched string when matched" do
    @s.skip(/This/)
    @s.matched.should == "This"
  end

  it "clears the matched string when not matched" do
    @s.skip(/This/)
    @s.matched.should == "This"
    @s.skip(/foo/)
    @s.matched.should be_nil
  end
end
