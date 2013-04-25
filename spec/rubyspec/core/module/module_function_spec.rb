require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Module#module_function with specific method names" do
  it "creates duplicates of the given instance methods on the Module object" do
    m = Module.new do
      def test()  end
      def test2() end
      def test3() end

      module_function :test, :test2
    end

    m.respond_to?(:test).should  == true
    m.respond_to?(:test2).should == true
    m.respond_to?(:test3).should == false
  end

  it "returns the current module" do
    x = nil
    m = Module.new do
      def test()  end
      x = module_function :test
    end

    x.should == m
  end
end
