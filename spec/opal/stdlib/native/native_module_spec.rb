require 'native'

describe "Module#native_module" do
  module SomeModule
  end

  after {`delete Opal.global.SomeModule`}

  it "adds current constant to the global JS object" do
    SomeModule.native_module
    `Opal.global.SomeModule`.should == SomeModule
  end
end
