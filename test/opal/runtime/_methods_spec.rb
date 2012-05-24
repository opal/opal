class RuntimeMethodsSpec
end

class RuntimeMethodsSpec2
  def foo; end
  def bar; end
end

class RuntimeMethodsSpec3
  def woosh; end
end

class RuntimeMethodsSpec3
  def kapow; end
end

describe "Class._methods private array" do
  it "should store a list of all defined methods on classes as jsid's" do
    `#{RuntimeMethodsSpec}._methods`.should == []
    `#{RuntimeMethodsSpec2}._methods`.should == ['$foo', '$bar']
  end

  it "correctly adds methods when reopening classes" do
    `#{RuntimeMethodsSpec3}._methods`.should == ['$woosh', '$kapow']
  end
end