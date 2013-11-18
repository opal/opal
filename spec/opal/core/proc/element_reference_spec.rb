describe "Proc#[]" do
  it "invokes self" do
    Proc.new { "test!" }[].should == "test!"
    lambda { "test!" }[].should == "test!"
    proc { "test!" }[].should == "test!"
  end

  it "sets self's parameters to the given values" do
    Proc.new { |a, b| a + b }[1, 2].should == 3
    Proc.new { |*args| args }[1, 2, 3, 4].should == [1, 2, 3, 4]
    Proc.new { |_, *args| args }[1, 2, 3].should == [2, 3]

    lambda { |a, b| a + b }[1, 2].should == 3
    lambda { |*args| args }[1, 2, 3, 4].should == [1, 2, 3, 4]
    lambda { |_, *args| args }[1, 2, 3].should == [2, 3]

    proc { |a, b| a + b }[1, 2].should == 3
    proc { |*args| args }[1, 2, 3, 4].should == [1, 2, 3, 4]
    proc { |_, *args| args }[1, 2, 3].should == [2, 3]
  end
end
