require 'spec_helper'

describe "Module#attr_accessor" do
  it "can be passed a splat of arguments" do
    eval "class OpalAttrAccessorSpec; attr_accessor *%w{foo bar baz}; end"
    OpalAttrAccessorSpec.new.foo.should be_nil
  end
end
