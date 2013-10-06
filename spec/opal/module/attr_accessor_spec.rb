require 'spec_helper'

module AttrAccessorSpec
  module M
    attr_accessor :foo
  end

  class C
    include M
  end
end

describe "Module#attr_accessor" do
  it "can be passed a splat of arguments" do
    eval "class OpalAttrAccessorSpec; attr_accessor *%w{foo bar baz}; end"
    OpalAttrAccessorSpec.new.foo.should be_nil
  end

  describe "inside a module" do
    it "defines methods that get donated to a class when included" do
      obj = AttrAccessorSpec::C.new
      obj.foo = 100
      obj.foo.should == 100
    end
  end
end
