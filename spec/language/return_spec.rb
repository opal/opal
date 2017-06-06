module ReturnSpecs
  def self.returns
    return 123
    return 456
  end
  
  def self.returns_nothing
    return
  end
  
  def self.returns_from_block
    tap do
      return 123
    end
    456
  end
  
  def self.returns_block(&bk)
    bk
  end
  
  def self.returns_block_which_returns
    returns_block do
      return 123
    end
  end
end

describe "The return statement" do
  it "returns nil if no operand is given" do
    ReturnSpecs.returns_nothing.should == nil
  end
  
  it "stops execution of the current method" do
    ReturnSpecs.returns.should == 123
  end
  
  describe "in a block" do
    it "stops execution of the enclosing method" do
      ReturnSpecs.returns_from_block.should == 123
    end
    
    it "raises LocalJumpError if out of scope of enclosing method" do
      lambda {
        ReturnSpecs.returns_block_which_returns.call
      }.should raise_error(LocalJumpError)
    end
  end
end