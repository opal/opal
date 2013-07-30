require 'spec_helper'

describe Opal::Parser do
  it "parses operators before \n in command calls" do
    [:<<, :>>, :|, :^, :&, :<=>, :==, :===, :=~, :>, :>=, :<, :<=, :<<, :>>, :%, :**].each do |mid|
      opal_parse("self #{mid}\nself").should == [:call, [:self], mid, [:arglist, [:self]]]
    end
  end
end
