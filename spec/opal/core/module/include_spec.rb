require 'spec_helper'

module ModuleIncludeSpecs
  module A
    def initialize
      $ScratchPad << :A
      super
    end
  end

  module B
    def initialize
      $ScratchPad << :B
      super
    end
  end

  module C
    def initialize
      $ScratchPad << :C
      super
    end
  end

  module D
    def initialize
      $ScratchPad << :D
      super
    end
  end

  class Test
    include A
    prepend B
    prepend C
    include D

    def initialize
      $ScratchPad << :Test
      super
    end
  end
end

describe 'Module#include' do
  describe 'called after #prepend' do
    it 'inserts the module after self in the ancestor chain' do
      ModuleIncludeSpecs::Test.ancestors.take(5).should == [
        ModuleIncludeSpecs::C,
        ModuleIncludeSpecs::B,
        ModuleIncludeSpecs::Test,
        ModuleIncludeSpecs::D,
        ModuleIncludeSpecs::A,
      ]
    end

    it 'modifies the prototype chain as expected' do
      $ScratchPad = []
      ModuleIncludeSpecs::Test.new
      $ScratchPad.should == [:C, :B, :Test, :D, :A]
    end
  end
end
