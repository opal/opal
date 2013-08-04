require File.expand_path('../../../spec_helper', __FILE__)
#require File.expand_path('../fixtures/classes', __FILE__)

describe "Numeric#step" do
  before :each do
    ScratchPad.record []
    @prc = lambda { |x| ScratchPad << x }
  end

  it "defaults to step = 1" do
    1.step(5, &@prc)
    ScratchPad.recorded.should == [1, 2, 3, 4, 5]
  end
end
