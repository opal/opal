module BlockGivenSpecs
  def self.is_block_given
    block_given?
  end

  def self.calls_block_given_with_block(&x)
    is_block_given(&x)
  end
end

describe "Kernel#block_given?" do
  it "can be used outside of a method scope" do
    block_given?
  end
  
  it "can check if a block was given" do
    BlockGivenSpecs.is_block_given.should == false
    BlockGivenSpecs.is_block_given {}.should == true
  end
  
  it "works with explicitly passed blocks" do
    BlockGivenSpecs.calls_block_given_with_block.should == false
    BlockGivenSpecs.calls_block_given_with_block {}.should == true
  end
  
  it "works with #to_proc'd blocks" do
    BlockGivenSpecs.is_block_given(&nil).should == false
    BlockGivenSpecs.is_block_given(&:x).should == true
  end
end