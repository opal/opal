require 'native'

describe "Class#native_alias" do
  it "exposes a method to javascript without the '$' prefix" do
    klass = Class.new {
      def a
        2
      end

      native_alias :a, :a
    }
    instance = klass.new
    `instance.a()`.should == 2
  end

  it "raises if the aliased method isn't defined" do
    Class.new do
      lambda {
        native_alias :a, :not_a_method
      }.should raise_error(
        NameError,
        %r{undefined method `not_a_method' for class `#<Class:0x\w+>'}
      )
    end
  end
end
