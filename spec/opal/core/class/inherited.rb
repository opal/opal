module ModuleInheritedTestModule
  class A
    def self.inherited(subclass)
      $ScratchPad << subclass.name
    end
  end
end

describe 'Class#inherited' do
  it 'gets called after setting a base scope of the subclass' do
    $ScratchPad = []
    module ModuleInheritedTestModule
      class B < A
      end
    end
    $ScratchPad.should == ['ModuleInheritedTestModule::B']
  end
end
