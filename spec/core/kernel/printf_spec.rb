describe "Kernel#printf" do
  it "returns nil if called with no arguments" do
    printf.should == nil
  end

  it "returns nil if called with arguments" do
    printf("%d", 123).should == nil
  end
end
