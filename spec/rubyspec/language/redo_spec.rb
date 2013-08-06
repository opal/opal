require File.expand_path('../../spec_helper', __FILE__)

describe "The redo statement" do
  it "restarts block execution if used within block" do
    a = []
    lambda {
      a << 1
      redo if a.size < 2
      a << 2
    }.call
    a.should == [1, 1, 2]
  end

  it "re-executes the closest loop" do
    exist = [2,3]
    processed = []
    order = []
    [1,2,3,4].each do |x|
      order << x
      begin
        processed << x
        if(exist.include?(x))
          raise StandardError, "included"
        end
      rescue StandardError => e
        exist.delete(x)
        redo
      end
    end
    processed.should == [1,2,2,3,3,4]
    exist.should == []
    order.should == [1,2,2,3,3,4]
  end

  it "re-executes the last step in enumeration" do
    list = []
    [1,2,3].each do |x|
      list << x
      break if list.size == 6
      redo if x == 3
    end
    list.should == [1,2,3,3,3,3]
  end

  # The #count method is on 1.9, but this causes SyntaxError,
  # Invalid redo in 1.9
  quarantine! do
    it "triggers ensure block when re-executing a block" do
      list = []
      [1,2,3].each do |x|
        list << x
        begin
          list << 10*x
          # causes SyntaxError in 1.9
          # redo if list.count(1) == 1
        ensure
          list << 100*x
        end
      end
      list.should == [1,10,100,1,10,100,2,20,200,3,30,300]
    end
  end
end

# language_version __FILE__, "redo"
