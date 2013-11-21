describe "Proc#call" do
  it "invokes self" do
    Proc.new { "test!" }.call.should == "test!"
    lambda { "test!" }.call.should == "test!"
    proc { "test!" }.call.should == "test!"
  end

  it "sets self's parameters to the given values" do
    Proc.new { |a, b| a + b }.call(1, 2).should == 3
    Proc.new { |*args| args }.call(1, 2, 3, 4).should == [1, 2, 3, 4]
    Proc.new { |_, *args| args }.call(1, 2, 3).should == [2, 3]

    lambda { |a, b| a + b }.call(1, 2).should == 3
    lambda { |*args| args }.call(1, 2, 3, 4).should == [1, 2, 3, 4]
    lambda { |_, *args| args }.call(1, 2, 3).should == [2, 3]

    proc { |a, b| a + b }.call(1, 2).should == 3
    proc { |*args| args }.call(1, 2, 3, 4).should == [1, 2, 3, 4]
    proc { |_, *args| args }.call(1, 2, 3).should == [2, 3]
  end
end