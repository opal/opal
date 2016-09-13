class RescueReturningSpec
  def single
    begin
      raise "ERROR"
    rescue
      :foo
    end
  end

  def multiple
    begin
      raise "ERROR"
    rescue
      to_s
      :bar
    end
  end

  def empty_rescue
    begin
      raise "ERROR"
    rescue
    end
  end
end

describe "The rescue keyword" do
  it "returns last value of expression evaluated" do
    RescueReturningSpec.new.single.should == :foo
    RescueReturningSpec.new.multiple.should == :bar
  end

  it "returns nil if no expr given in rescue body" do
    RescueReturningSpec.new.empty_rescue.should be_nil
  end

  it "by default, catch StandardError, not all Exception" do
    lambda { begin;raise Exception.new;rescue;end }.should raise_error
    lambda { begin;raise "err";rescue;end }.should_not raise_error

    # one line rescue
    lambda { raise Exception rescue nil }.should raise_error(Exception)
    lambda { raise "err" rescue nil }.should_not raise_error
    (raise "err" rescue "foo").should == "foo"
    ("err" rescue "foo").should == "err"
  end

  it 'Fix using more than two "rescue" in sequence #1269' do
    $ScratchPad = []
    # As a statement
    begin
      raise IOError, 'foo'
    rescue RangeError              # this one is correct
    rescue TypeError               # miss a return
    rescue IOError                 # following two lines disappear in js
      $ScratchPad << "I got #{$!.message}"
    end
    $ScratchPad.last.should == "I got foo"

    # As an expression
    a = begin
      raise IOError, 'foo'
    rescue RangeError              # this one is correct
    rescue TypeError               # miss a return
    rescue IOError                 # following two lines disappear in js
      "I got #{$!.message}"
    end
    a.should == "I got foo"
  end

  context 'JS::Error' do
    it 'handles raw js throws' do
      begin
        `throw { message: 'foo' }`
        nil
      rescue JS::Error => e
        e.JS[:message]
      end.should == 'foo'
    end

    it 'handles other Opal error' do
      begin
        raise 'bar'
      rescue JS::Error => e
        e.message
      end.should == 'bar'
    end

    it 'can be combined with other classes to catch js errors' do
      begin
        `throw { message: 'baz' }`
        nil
      rescue JS::Error, RuntimeError => e
        e.JS[:message]
      end.should == 'baz'
    end

    it 'can be combined with other classes to catch Opal errors' do
      begin
        raise 'quux'
      rescue JS::Error, RuntimeError => e
        e.message
      end.should == 'quux'
    end
  end
end
