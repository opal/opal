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
    expect(BlockGivenSpecs.is_block_given).to eq(false)
    expect(BlockGivenSpecs.is_block_given {}).to eq(true)
  end
  
  it "works with explicitly passed blocks" do
    expect(BlockGivenSpecs.calls_block_given_with_block).to eq(false)
    expect(BlockGivenSpecs.calls_block_given_with_block {}).to eq(true)
  end
  
  it "works with #to_proc'd blocks" do
    expect(BlockGivenSpecs.is_block_given(&nil)).to eq(false)
    expect(BlockGivenSpecs.is_block_given(&:x)).to eq(true)
  end
end if false
