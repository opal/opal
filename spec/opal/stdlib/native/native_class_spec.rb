require 'native'

describe "Class#native_class" do
  class SomeClass
  end

  after {`delete Opal.global.SomeClass`}

  it "adds current constant to the global JS object" do
    SomeClass.native_class
    `Opal.global.SomeClass`.should == SomeClass
  end

  it 'aliases Class#new to the unprefixed new method in JS world' do
    SomeClass.native_class
    `Opal.global.SomeClass.new()`.is_a?(SomeClass).should == true
  end
end
