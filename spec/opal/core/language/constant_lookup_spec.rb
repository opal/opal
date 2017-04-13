ConstantLookupSpec_TopDef = 123
def self._ConstantLookupSpec_TopDef
  ConstantLookupSpec_TopDef
end
ConstantLookupSpec_TopDefValue = _ConstantLookupSpec_TopDef

module ConstantLookupSpec_Module
end
class ConstantLookupSpec_Class
end

module ConstantLookupSpec_Namespace
  class NamespacedClass
    def self.foo
      ConstantLookupSpec_TopDef
    end
  end
end


describe 'constant lookup' do
  it 'can reach constants from methods defined at top level' do
    ::ConstantLookupSpec_TopDefValue.should == 123
    ::ConstantLookupSpec_TopDefValue.should == ::ConstantLookupSpec_TopDef
    ::ConstantLookupSpec_TopDefValue.should == ConstantLookupSpec_TopDef
  end

  it 'cannot reach a toplevel constant from a qualified lookup on another toplevel constant' do
    ->{ConstantLookupSpec_Module::ConstantLookupSpec_Class}.should raise_error(NameError)

    # When the cref is a module then ::Object is added to the search
    ->{ConstantLookupSpec_Class::ConstantLookupSpec_Module}.should_not raise_error
  end

  it 'can reach a constant from inside a namespaced class' do
    ConstantLookupSpec_Namespace::NamespacedClass.foo.should == 123
  end
end
