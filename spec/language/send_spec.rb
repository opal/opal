require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../fixtures/send', __FILE__)

specs = LangSendSpecs

describe "Invoking a method" do
  it "with an object as a block used 'to_proc' for coercion" do
    o = LangSendSpecs::ToProc.new(:from_to_proc)

    specs.makeproc(&o).call.should == :from_to_proc

    specs.yield_now(&o).should == :from_to_proc
  end
end
