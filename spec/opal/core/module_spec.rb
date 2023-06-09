module ModuleSubclassIncludedSpec
  class Module1 < ::Module
    def included(_descendant)
      $ScratchPad << 'A included'
    end
  end

  class Module2 < Module1
    def included(_descendant)
      $ScratchPad << 'B included'
    end
  end
  M0 = Module.new
  M1 = Module1.new
  M2 = Module2.new
end

module ModuleCVarSpec
  module Mod0
    def cvar0; @@cvar; end
    def cvarx0; @@cvarx ||= 5; end
    def cvary0; @@cvary; 0; end
    def cvarz0; @@cvarz = @@cvarz || 5; end
  end

  module Mod1
    include Mod0
    @@cvar = 10
    def cvar1; @@cvar; end
    def cvar1=(new); @@cvar=new; end
  end

  module Mod2
    include Mod1
    def cvar2; @@cvar; end
    def cvar2=(new); @@cvar=new; end
  end
end

describe 'Module' do
  it '#included gets called in subclasses (regression for https://github.com/opal/opal/issues/1900)' do
    $ScratchPad = []
    klass = Class.new
    klass.include ::ModuleSubclassIncludedSpec::M0
    klass.include ::ModuleSubclassIncludedSpec::M1
    klass.include ::ModuleSubclassIncludedSpec::M2
    $ScratchPad.should == ['A included', 'B included']
  end

  it "can access ancestor's @@cvar" do
    klass = Class.new
    klass.include ::ModuleCVarSpec::Mod2
    klass.new.cvar1.should == 10
    klass.new.cvar2.should == 10
    klass.new.cvar2 = 50
    klass.new.cvar1.should == 50
    klass.new.cvar2.should == 50
    klass.new.cvarx0.should == 5
    klass.new.cvary0.should == 0
    ->{ klass.new.cvarz0 }.should raise_error NameError
    ->{ klass.new.cvar0 }.should raise_error NameError
  end

  it "can be set to a constant while being frozen" do
    OPAL_SPEC_MODULE = Module.new.freeze
    OPAL_SPEC_CLASS = Class.new.freeze

    OPAL_SPEC_MODULE.class.should == Module
    OPAL_SPEC_CLASS.class.should == Class
  end

  describe "updates iclass" do
    def included_structures
      mod = Module.new { def method_to_remove; end }
      klass = Class.new { include mod }
      [mod, klass]
    end

    def prepended_structures
      mod = Module.new { def method_to_remove; end }
      klass = Class.new { prepend mod }
      [mod, klass]
    end

    it "whenever a new method is added to an included module" do
      mod, klass = included_structures
      ->{ klass.new.nonexistent }.should raise_error NoMethodError
      mod.class_exec { def added_method; end }
      ->{ klass.new.added_method }.should_not raise_error NoMethodError
    end

    it "whenever a new method is added to a prepended module" do
      mod, klass = prepended_structures
      ->{ klass.new.nonexistent }.should raise_error NoMethodError
      mod.class_exec { def added_method; end }
      ->{ klass.new.added_method }.should_not raise_error NoMethodError
    end

    it "whenever a method is removed from an included module" do
      mod, klass = included_structures
      ->{ klass.new.nonexistent }.should raise_error NoMethodError
      ->{ klass.new.method_to_remove }.should_not raise_error NoMethodError
      mod.class_exec { remove_method :method_to_remove }
      ->{ klass.new.method_to_remove }.should raise_error NoMethodError
    end

    it "whenever a method is removed from a prepended module" do
      mod, klass = prepended_structures
      ->{ klass.new.nonexistent }.should raise_error NoMethodError
      ->{ klass.new.method_to_remove }.should_not raise_error NoMethodError
      mod.class_exec { remove_method :method_to_remove }
      ->{ klass.new.method_to_remove }.should raise_error NoMethodError
    end
  end
end
