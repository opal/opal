require 'spec_helper'

describe "Native#[]" do
  before do
    %x{
      var obj = {
        foo: 'FOO',

        str: 'LOL',
        num: 42,
        on: true,
        off: false
      };
    }

    @native = `obj`
  end

  it "returns a value from the native object" do
    @native['foo'].should == "FOO"
  end

  it "returns nil for a key not existing on native object" do
    @native['bar'].should be_nil
  end

  it "returns direct values for strings, numerics and booleans" do
    @native['str'].should == 'LOL'
    @native['num'].should == 42
    @native['on'].should == true
    @native['off'].should == false
  end
end

