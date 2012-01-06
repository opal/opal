require File.expand_path('../../../spec_helper', __FILE__)
#require 'forwardable'

#class ForwardableTest
  #extend Forwardable

  #def initialize
    #@some_ivar = ['a', 'b', 'c']
    #@blah = [1, 2, 3, 4, 5, 6]
  #end

  #def foo
    #@some_ivar
  #end

  #def wizz
    #@blah
  #end

  #def_instance_delegator :@some_ivar, :length
  #def_instance_delegator :@blah, :length, :blah

  #def_instance_delegator :foo, :reverse
  #def_instance_delegator :wizz, :reverse, :fizz
#end

describe "Forwardable#def_instance_delegator" do
  before do
    @tester = ForwardableTest.new
  end

  it "should define new instance methods" do
    @tester.respond_to?(:length).should be_true 
    @tester.respond_to?(:blah).should be_true

    @tester.respond_to?(:reverse).should be_true
    @tester.respond_to?(:fizz).should be_true
  end

  it "should forward method calls to given ivars" do
    @tester.length.should == 3
    @tester.blah.should == 6
  end

  it "should forward method calls to given accessors" do
    @tester.reverse.should == ['c', 'b', 'a']
    @tester.fizz.should == [6, 5, 4, 3, 2, 1]
  end
end
