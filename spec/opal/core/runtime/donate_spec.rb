require 'spec_helper'

module RuntimeDonatingMethods
  module A
    def baz
      'a'
    end
  end

  module B
  end

  class C
    include A
    include B

    def foo; 'c'; end
  end

  module B
    def foo; 'b'; end
    def bar; 'b'; end
    def baz; 'b'; end
  end

  module A
    def bar; 'a'; end
  end
end

describe 'Donating methods in the runtime' do
  before do
    @c = RuntimeDonatingMethods::C.new
  end

  it 'class methods should not get overwritten by methods from modules' do
    @c.foo.should == 'c'
  end

  it 'methods defined in modules should respect the include order in a class' do
    @c.bar.should == 'b'
    @c.baz.should == 'b'
  end
end
