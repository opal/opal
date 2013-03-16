module DefinedSpecs
  class Basic
    A = 42

    def a_defined_method
    end
  end
end

describe "The defined? keyword for literals" do
  it "returns 'self' for self" do
    ret = defined?(self)
    ret.should == "self"
  end

  it "returns 'nil' for nil" do
    ret = defined?(nil)
    ret.should == "nil"
  end

  it "returns 'true' for true" do
    ret = defined?(true)
    ret.should == "true"
  end

  it "returns 'false' for false" do
    ret = defined?(false)
    ret.should == "false"
  end
end

describe "The defined? keyword when called with a method name" do
  describe "without a receiver" do
    it "returns 'method' if the method is defined" do
      defined?(puts).should == "method"
    end

    it "returns nil if the method is not defined" do
      defined?(defined_specs_undefined_method).should be_nil
    end
  end

  describe "having a module as a receiver" do
    it "returns 'method' if the method is defined" do
      defined?(Kernel.puts).should == "method"
    end

    pending "returns nil if the method is private" do
      defined?(Object.print).should be_nil
    end

    pending "returns nil if the method is protected" do
      defined?(DefinedSpecs::Basic.new.protected_method).should be_nil
    end

    it "returns nil if the method is not defined" do
      defined?(Kernel.defined_specs_undefined_method).should be_nil
    end
  end

  describe "having a local variable as receiver" do
    it "returns 'method' if the method is defined" do
      obj = DefinedSpecs::Basic.new
      defined?(obj.a_defined_method).should == "method"
    end

    it "returns nil if the method is not defined" do
      obj = DefinedSpecs::Basic.new
      defined?(obj.an_undefined_method).should be_nil
    end
  end

  describe "having an instance variable as receiver" do
    it "returns 'method' if the method is defined" do
      @defined_specs_obj = DefinedSpecs::Basic.new
      defined?(@defined_specs_obj.a_defined_method).should == "method"
    end

    it "returns nil if the method is not defined" do
      @defined_specs_obj = DefinedSpecs::Basic.new
      defined?(@defined_specs_obj.an_undefined_method).should be_nil
    end
  end
end

describe "The defined? keyword for ivars" do
  it "returns 'instace-variable' if assigned" do
    @assigned_ivar = "some value"
    ret = defined?(@assigned_ivar)
    ret.should == "instance-variable"
  end

  it "returns 'instace-variable' if not assigned" do
    ret = defined?(@unassigned_ivar)
    ret.should == "nil"
  end
end

