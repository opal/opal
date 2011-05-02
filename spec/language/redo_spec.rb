
describe "The redo statement" do
  it "restarts block execution if used within block" do
    a = []
    lambda {
      a << 1
      # redo if a.size < 2
      a << 2
    }.call
    a.should == [1, 1, 2]
  end
  
  it "re-executes the closest loop"
  
  it "re-executes the last step in enumeration" do
    list = []
    [1,2,3].each do |x|
      list << x
      # break if list.size == 6
      # redo if x == 3
    end
    list.should == [1,2,3,3,3,3]
  end
end
