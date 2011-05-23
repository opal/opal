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

  it "returns a value to the method invoking the method yielding to the block" do
    @program.break_value
    ScratchPad.recorded.should == [:a, :aa, :b, :break, :d]
  end
end

describe "Executing break from within a block" do

  before :each do
    ScratchPad.clear
  end

  it "returns from the invoking singleton method" do
    obj = Object.new
    def obj.meth_with_block
      yield
      fail "break didn't break from the singleton method"
    end
    obj.meth_with_block { break :value }.should == :value
  end

  it "returns from the invoking method with the argument to break" do
    class BreakTest
      def self.meth_with_block
        yield
        fail "break didn't break from the method"
      end
    end
    BreakTest.meth_with_block { break :value }.should == :value
  end

  it "returns from the original invoking method even in case of chained calls" do
    class BreakTest
      # case #1: yield
      def self.meth_with_yield(&b)
        yield
        fail "break returned from yield to wrong place"
      end
      def self.invoking_method(&b)
        meth_with_yield(&b)
        fail "break returns from 'meth_with_yield' method to wrong place"
      end
    end

    # this calls a method that calls another method that yields to the block
    BreakTest.invoking_method do
      break
      fail "break didn't, well, break"
    end
  end
end

