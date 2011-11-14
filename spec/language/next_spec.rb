require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../fixtures/next', __FILE__)

describe "The next statement from within the block" do
  before :each do
    ScratchPad.record []
  end

  it "ends block execution" do
    a = []
    lambda {
      a << 1
      next
      a << 2
    }.call
    a.should == [1]
  end

  it "causes block to return nil if invoked without arguments" do
    lambda { 123; next; 456 }.call.should == nil
  end

  it "causes block to return nil if invoked with an empty expression" do
    lambda { next (); 456 }.call.should be_nil
  end

  it "returns the argument passed" do
    lambda { 123; next 234; 345 }.call.should == 234
  end

  it "returns to the invoking method" do
    NextSpecs.yielding_method(nil) { next }.should == :method_return_value
  end

  it "returns to the invoking method, with the specified value" do
    NextSpecs.yielding_method(nil) {
      next nil;
      fail("next didn't end the block execution")
    }.should == :method_return_value

    NextSpecs.yielding_method(1) {
      next 1;
      fail("next didn't end the block execution")
    }.should == :method_return_value

    NextSpecs.yielding_method([1, 2, 3]) {
      next 1, 2, 3;
      fail("next didn't end the block execution")
    }.should == :method_return_value
  end

  it "returns to the currently yielding method in case of chained calls" do
    class ChainedNextTest
      def self.meth_with_yield(&b)
        yield.should == :next_return_value
        :method_return_value
      end
      def self.invoking_method(&b)
        meth_with_yield(&b)
      end
      def self.enclosing_method
        invoking_method do
          next :next_return_value
          :wrong_return_value
        end
      end
    end

    ChainedNextTest.enclosing_method.should == :method_return_value
  end

  it "causes ensure blocks to run" do
    [1].each do |i|
      begin
        ScratchPad << :begin
        next
      ensure
        ScratchPad << :ensure
      end
    end

    ScratchPad.recorded.should == [:begin, :ensure]
  end
end

describe "The next statement" do
  before :each do
    ScratchPad.record []
  end

  describe "in a while loop" do
    describe "when not passed an argument" do
      before :each do
        ScratchPad.record []
      end

      it "causes ensure blocks to run" do
        NextSpecs.while_next(false)

        ScratchPad.recorded.should == [:begin, :ensure]
      end

      it "causes ensure blocks to run when nested in an block" do
        NextSpecs.while_within_iter(false)

        ScratchPad.recorded.should == [:begin, :ensure]
      end
    end
  end
end
