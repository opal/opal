describe "Array#reverse_each" do
  before :each do
    ScratchPad.record []
  end

  it "traverses array in reverse order and pass each element to block" do
    [1, 3, 4, 6].reverse_each { |i| ScratchPad << i }
    ScratchPad.recorded.should == [6, 4, 3, 1]
  end

  it "returns self" do
    a = [:a, :b, :c]
    a.reverse_each { |x| }.should equal(a)
  end
end