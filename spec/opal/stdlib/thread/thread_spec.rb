require 'thread'

# Our implementation of Thread only supports faux thread-local variables.
# Since we can't actually create a thread, nothing in rubyspec will run.
describe Thread do
  it "returns a value for current" do
    Thread.current.should_not be_nil
  end

  it "only has current in list" do
    Thread.list.should == [Thread.current]
  end

  it "does not allow creation of new threads" do
    lambda do
      Thread.new {}
    end.should raise_error(NotImplementedError)
  end

  describe "local storage" do
    before do
      @current = Thread.current
      @current.send(:core_initialize!)
    end

    it "stores fiber-local variables" do
      @current[:a] = 'hello'
      @current[:a].should == 'hello'
    end

    it "returns fiber-local keys that are assigned" do
      @current[:a] = 'hello'
      @current.key?(:a).should be_true
      @current.keys.should === ['a']
    end

    it "considers fiber-local keys, as symbols or strings equal" do
      @current[:a]  = 1
      @current['a'] = 2
      @current.keys.size.should == 1
      @current[:a].should == 2
    end

    it "implements thread-local variables" do
      @current.thread_variable_set('a', 1)
      @current.thread_variable_get('a').should == 1
      @current.thread_variables.should == ['a']
    end

    it "distinguishes between fiber-local and thread-local variables" do
      @current[:a] = 1
      @current.thread_variables.should == []

      @current.thread_variable_set(:a, 2)

      @current[:a].should == 1
      @current.thread_variable_get(:a).should == 2
    end
  end
end
