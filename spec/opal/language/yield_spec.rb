require 'spec_helper'

fixture = Class.new do
  def single
    yield 1
    yield 2
  end

  def multiple
    yield 1, 2
    yield 3, 4
  end
end

describe "The yield call" do
  before :each do
    ScratchPad.record []
    @y = fixture.new
  end

  describe "taking a single argument" do
    it "can yield to a lambda with return" do
      lambda = -> i {
        ScratchPad << i
        return
      }
      @y.single(&lambda)
      ScratchPad.recorded.should == [1, 2]
    end
  end

  describe "taking multiple arguments" do
    it "can yield to a lambda with return" do
      lambda = -> i, j {
        ScratchPad << i
        ScratchPad << j
        return
      }
      @y.multiple(&lambda)
      ScratchPad.recorded.should == [1, 2, 3, 4]
    end
  end
end
