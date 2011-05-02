
describe "The next statement from within the block" do
  it "ends block execution" do
    a = []
    lambda {
      a << 1
      # next
      a << 2
    }.call
    a.should == [1]
  end

  it "causes block to return nil if invoked without arguments" do
    # lambda { 123; next; 456 }.call.should == nil
  end

  it "causes block to return nil if invoked with an empty expression" do
    # lambda { next (); 456 }.call.should == nil
  end

  it "returns the argument passed" do
    # lambda { 123; next 234; 345 }.call.should == 234
  end
end

