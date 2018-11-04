module JavaScriptAPIFixtures
  class A
  end

  class A::B
  end
end

require 'spec_helper'
require 'native'

describe "JavaScript API" do
  it "allows to acces scopes on `Opal` with dots (regression for #1418)" do
    `Opal.JavaScriptAPIFixtures.A.B`.should == JavaScriptAPIFixtures::A::B
  end
end
