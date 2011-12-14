require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../fixtures/send', __FILE__)

specs = LangSendSpecs

describe "Invoking a method" do
  describe "with zero arguments" do
    it "requires no arguments passed" do
      specs.fooM0.should == 100
    end

    it "raises ArgumentError if the method has a positive arity" do
      #lambda {
      #  specs.fooM1
      #}.should raise_error(ArgumentError)
    end
  end

  it "with an object as a block used 'to_proc' for coercion" do
    o = LangSendSpecs::ToProc.new(:from_to_proc)

    specs.makeproc(&o).call.should == :from_to_proc

    specs.yield_now(&o).should == :from_to_proc
  end
end
