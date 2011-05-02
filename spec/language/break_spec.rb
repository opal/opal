require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../fixtures/break', __FILE__)

describe "The break statement in a block" do
  before :each do
    ScratchPad.record []
    @program = BreakSpecs::Block.new
  end

  it "returns nil to method invoking the method yielding to the block when not passed an argument" do
    @program.break_nil
    ScratchPad.recorded.should == [:a, :aa, :b, nil, :d]
  end
end

# describe "Executing break from within a block" do
#   
#   it "returns from the invoking singleton method" do
#     obj = Object.new
#     def obj.meth_with_block
#       yield
#       raise "break didn't break from the singleton method"
#     end
#     obj.meth_with_block { break :value }.should == :value
#   end
# end
