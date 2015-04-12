require 'spec_helper'

describe '`Opal.hash`' do
  it 'converts object literals to hashes' do
    `Opal.hash({a: 1, b: 2})`.should == {a: 1, b: 2}
  end
end
