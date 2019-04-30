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

describe 'Module#included' do
  it 'gets called in subclasses (regression for https://github.com/opal/opal/issues/1900)' do
    $ScratchPad = []
    klass = Class.new
    klass.include ::ModuleSubclassIncludedSpec::M0
    klass.include ::ModuleSubclassIncludedSpec::M1
    klass.include ::ModuleSubclassIncludedSpec::M2
    $ScratchPad.should == ['A included', 'B included']
  end
end
