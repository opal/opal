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

module RuntimeMethodsSpec4
  def ding; end
end

module RuntimeMethodsSpec4
  def dong; end
end

class RuntimeMethodsSpec5
  include RuntimeMethodsSpec4

  def thor; end
end

describe "Class._methods private array" do
  it "should store a list of all defined methods on classes as jsid's" do
    `#{RuntimeMethodsSpec}._methods`.should == []
    `#{RuntimeMethodsSpec2}._methods`.should == ['$foo', '$bar']
  end

  it "correctly adds methods when reopening classes" do
    `#{RuntimeMethodsSpec3}._methods`.should == ['$woosh', '$kapow']
  end

  it "should store methods for modules" do
    `#{RuntimeMethodsSpec4}._methods`.should == ['$ding', '$dong']
  end

  it "should not include methods from included modules" do
    `#{RuntimeMethodsSpec5}._methods`.should == ['$thor']
  end
end