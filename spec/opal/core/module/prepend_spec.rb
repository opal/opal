require 'native'
describe "Module#prepend" do
  it "prepends the given instance methods on the target class" do
    m = Module.new do
      def test1() :m1 end
      def test2() :m2 end
    end
    c = Class.new do
      def test1() :c1 end
      def test3() :c3 end
    end
    c.prepend m

    c.new.test1.should == :m1
    c.new.test2.should == :m2
    c.new.test3.should == :c3
  end
end
