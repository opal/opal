describe "Kernel#p" do
  before { extend OutputSilencer }

  it "returns nil if called with no arguments" do
    silence_stdout { p.should == nil }
  end

  it "returns its argument if called with one argument" do
    silence_stdout { p(123).should == 123 }
  end

  it "returns all arguments as an Array if called with multiple arguments" do
    silence_stdout { p(1,2,3).should == [1,2,3] }
  end
end
