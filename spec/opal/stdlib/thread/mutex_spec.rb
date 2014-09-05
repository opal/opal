require 'thread'

describe Mutex do
  before do
    @mutex = Mutex.new
  end

  it "cannot be locked twice" do
    @mutex.lock
    lambda do
      @mutex.lock
    end.should raise_error(ThreadError)
  end

  it "reports locked? status" do
    @mutex.locked?.should be_false
    @mutex.lock
    @mutex.locked?.should be_true
  end

  it "reports locked? status with try_lock" do
    @mutex.try_lock.should be_true
    @mutex.locked?.should be_true
    @mutex.try_lock.should be_false
  end

  it "is locked and unlocked by synchronize" do
    @mutex.synchronize do
      @mutex.locked?.should be_true
    end
    @mutex.locked?.should be_false
  end

  it "will not be locked by synchronize if already locked" do
    @mutex.lock
    lambda do
      @mutex.synchronize {}
    end.should raise_error(ThreadError)
  end
end
