module EnsureSpec
  class Container
    attr_reader :executed

    def initialize
      @executed = []
    end

    def raise_in_method_with_ensure
      @executed << :method
      raise "An Exception"
    ensure
      @executed << :ensure
    end

    def raise_and_rescue_in_method_with_ensure
      @executed << :method
      raise "An Exception"
    rescue => e
      @executed << :rescue
    ensure
      @executed << :ensure
    end

    def implicit_return_in_method_with_ensure
      :method
    ensure
      :ensure
    end

    def explicit_return_in_method_with_ensure
      return :method
    ensure
      return :ensure
    end
  end
end

describe "An ensure block inside a begin block" do
  before :each do
    ScratchPad.record []
  end

  it "is executed when an exception is raised in it's corresponding begin block" do
    begin
      lambda {
        begin
          ScratchPad << :begin
          raise "An exception occured!"
        ensure
          ScratchPad << :ensure
        end
      }.should raise_error(RuntimeError)

      ScratchPad.recorded.should == [:begin, :ensure]
    end
  end

  it "is executed when an exception is raised and rescued in it's corresponding begin block" do
    begin
      begin
        ScratchPad << :begin
        raise "An exception occured!"
      rescue => e
        ScratchPad << :rescue
      ensure
        ScratchPad << :ensure
      end

      ScratchPad.recorded.should == [:begin, :rescue, :ensure]
    end
  end

  it "is executed when nothing is raised or thrown in it's corresponding begin block" do
    begin
      ScratchPad << :begin
    rescue
      ScratchPad << :rescue
    ensure
      ScratchPad << :ensure
    end

    ScratchPad.recorded.should == [:begin, :ensure]
  end

  it "has no return value" do
    begin
      :begin
    ensure
      :ensure
    end.should == :begin
  end
end

describe "An ensure block inside a method" do
  before(:each) do
    @obj = EnsureSpec::Container.new
  end

  it "is executed when an exception is raised in the method" do
    lambda { @obj.raise_in_method_with_ensure }.should raise_error(RuntimeError)
    @obj.executed.should == [:method, :ensure]
  end

  it "is executed when an exception is raised and rescued in the method" do
    @obj.raise_and_rescue_in_method_with_ensure
    @obj.executed.should == [:method, :rescue, :ensure]
  end

  it "has no impact on the method's implicit return value" do
    @obj.implicit_return_in_method_with_ensure.should == :method
  end

  it "has an impact on the method's explicit return value" do
    @obj.explicit_return_in_method_with_ensure.should == :ensure
  end
end