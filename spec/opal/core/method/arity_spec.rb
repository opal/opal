describe 'Method#arity' do
  # regression test https://github.com/opal/opal/issues/1424
  context 'when method was defined through attr_reader/attr_writer' do
    klass = Class.new do
      attr_accessor :attribute_name
    end
    klass.instance_method(:attribute_name).arity.should == 0
    klass.instance_method(:attribute_name=).arity.should == 1
  end
end
