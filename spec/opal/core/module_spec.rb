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
end
