class ArraySubclassSpec < Array
  def add_val(val)
    `this.push(val)`
    self
  end

  def foo
    :bar
  end
end

describe "Array subclasses" do
  it "should have their defined methods present on instances" do
    ArraySubclassSpec.new.foo.should == :bar
  end

  it "should correctly keep their length" do
    arr = ArraySubclassSpec.new
    arr.add_val :foo
    arr.length.should == 1
  end

  it "should have the correct class" do
    ArraySubclassSpec.new.class.should == ArraySubclassSpec
    Array.new.class.should == Array
  end

  it "is just an instance of the bridged constructor" do
    arr = ArraySubclassSpec.new
    `(arr.constructor === Array)`.should == true
  end
end