describe "Kernel#printf" do
  before { extend OutputSilencer }

  it "returns nil if called with no arguments" do
    silence_stdout { printf.should == nil }
  end

  it "returns nil if called with arguments" do
    silence_stdout { printf("%d", 123).should == nil }
  end
end
