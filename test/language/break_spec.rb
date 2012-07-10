module BreakSpecs
  class Driver
    def initialize(ensures=false)
      @ensures = ensures
    end

    def note(value)
      ScratchPad << value
    end
  end

  class Block < Driver
    def break_nil
      note :a
      note yielding {
        note :b
        break
        note :c
      }
      note :d
    end

    def break_value
      note :a
      note yielding {
        note :b
        break :break
        note :c
      }
      note :d
    end

    def yielding
      note :aa
      note yield
      note :bb
    end
  end
end

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

describe "Break inside a while loop" do
  describe "with a value" do
    it "exists the loop and returns the value" do
      a = while true; break; end;           a.should == nil
      a = while true; break nil; end;       a.should == nil
      a = while true; break 1; end;         a.should == 1
      a = while true; break []; end;        a.should == []
      a = while true; break [1]; end;       a.should == [1]
    end
  end

  it "stops a while loop when run" do
    i = 0
    while true
      break if i == 2
      i+=1
    end
    i.should == 2
  end

  it "causes a call with a block to return when run" do
    at = 0
    0.upto(5) do |i|
      at = i
      break i if i == 2
    end.should == 2
    at.should == 2
  end
end