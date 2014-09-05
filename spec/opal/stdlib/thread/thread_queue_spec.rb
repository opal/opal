require 'thread'

describe Thread::Queue do
  before do
    @queue = Thread::Queue.new
  end

  it "is aliased as ::Queue" do
    ::Thread::Queue.should == ::Queue
  end

  it "will not allow deadlock" do
    lambda do
      @queue.pop
    end.should raise_error(ThreadError)
  end

  it "pops in FIFO order" do
    @queue.push(1)
    @queue.push(2)

    @queue.pop.should == 1
    @queue.pop.should == 2
  end

  it "can be cleared by clear" do
    @queue.push(1)
    @queue.clear
    @queue.size.should == 0
    @queue.empty?.should be_true
  end
end
