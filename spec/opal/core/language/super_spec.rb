describe 'super without explicit argument' do
  it 'passes arguments named with js reserved word' do
    parent = Class.new do
      def test_args(*args) = args
      def test_rest_args(*args) = args
      def test_kwargs(**args) = args
      def test_rest_kwargs(**args) = args
    end
    klass = Class.new(parent) do
      def test_args(native) = super
      def test_rest_args(*native) = super
      def test_kwargs(native:) = super
      def test_rest_kwargs(**native) = super
    end

    klass.new.test_args(1).should == [1]
    klass.new.test_rest_args(2).should == [2]
    klass.new.test_kwargs(native: 3).should == {native: 3}
    klass.new.test_rest_kwargs(native: 4).should == {native: 4}
  end
end
