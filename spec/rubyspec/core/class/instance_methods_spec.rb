class InstanceMethodsSpec
  def foo; end
  def bar; end
  def baz; end
end

describe Class do
  describe '#instance_methods' do
    it 'returns an array of the instance method names for this class' do
      InstanceMethodsSpec.instance_methods.should == [:foo, :bar, :baz]
    end
  end
end