
describe "The return keyword" do
  it "returns any object directly" do
    def r; return 1; end
    r().should == 1
  end
  
  it "returns an single element array directly" do
    def r; return[1]; end
    r().should == [1]
  end
  
  it "returns an multi element array directly" do
    def r; return [1, 2]; end
    r().should == [1, 2]
  end
  
  it "returns nil be default" do
    def r; return; end
    r().should == nil
  end
  
  # describe "within a begin" do
    # it "executes ensure before re"
  # end
  
  describe "within a block" do
    it "raises a LocalJumpError if there is no lexicaly enclosing method" #do
      # def f; yield; end
      # lambda { f { return 5 } }
    # end
    
    it "causes lambda to return nil if invoked without any arguments" do
      lambda { return; 456 }.call.should == nil
    end
  
  end
  
  describe "within two blocks" do
    it "causes the method that lexically encloses the block to return" do
      def f
        1.times { 1.times { return true }; false }; false
      end
      f.should == true
    end
  end
end
