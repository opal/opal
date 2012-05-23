describe "Enumerable#find" do
  before :each do
    ScratchPad.record []
    @elements = [2, 4, 6, 8, 10]
    @numerous = EnumerableSpecs::Numerous.new(*@elements)
    @empty = []
  end

  it "passes each entry in enum to block while block when block is false" do
    visited_elements = []
    @numerous.find do |element|
      visited_elements << element
      false
    end
    visited_elements.should == @elements
  end

  it "returns nil when the block is false and there is no ifnone proc given" do
    @numerous.find {|e| false}.should == nil
  end

  it "returns the first element for which the block is not false" do
    @elements.each do |element|
      @numerous.find {|e| e > element -1 }.should == element
    end
  end

  it "returns the value of the ifnone proc if the block is false" do
    fail_proc = lambda { "cheeseburgers" }
    @numerous.find(fail_proc) {|e| false }.should == "cheeseburgers"
  end

  it "doesn't call the ifnone proc if an element is found" do
    fail_proc = lambda { raise "This should't have been called" }
    @numerous.find(fail_proc) {|e| 2 == @elements.first }.should == 2
  end

  it "calls the ifnone proc only once when the block is false" do
    times = 0
    fail_proc = lambda { times += 1; raise if times > 1; "cheeseburgers" }
    @numerous.find(fail_proc) {|e| false }.should == "cheeseburgers"
  end

  it "calls the ifnone proc when there are no elements" do
    fail_proc = lambda { "yay" }
    @empty.find(fail_proc) {|e| true}.should == "yay"
  end
end