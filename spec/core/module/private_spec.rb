require File.expand_path('../../../spec_helper', __FILE__)
# require File.expand_path('../fixtures/classes', __FILE__)

describe "Module#private" do
  it "makes the target method uncallable from other types" do
    obj = Object.new
    class << obj
      def foo; true; end
    end

    obj.foo.should == true

    class << obj
      private :foo
    end

    lambda { obj.foo }.should raise_error(NoMethodError)
    obj.foo
  end
end

