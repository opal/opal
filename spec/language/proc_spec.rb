class ProcSpec
  define_method :defined_method do
    self
  end

  def call_proc
    get_proc.call
  end

  def get_proc
    proc { self }
  end
end

describe "Procs" do
  before do
    @obj = ProcSpec.new
  end

  it "should use the 'self' value of wrapping scope" do
    @obj.call_proc.should eq(@obj)
  end

  it "instance_eval correctly sets proc self value" do
    arr = []
    arr.instance_eval(&@obj.get_proc).should eq(arr)
  end

  it "procs used by define_method use correct self value" do
    @obj.defined_method.should eq(@obj)
  end

  it "procs used by define_singleton_method use correct self value" do
    @obj.define_singleton_method(:bar) { self }
    @obj.bar.should eq(@obj)
  end
end
