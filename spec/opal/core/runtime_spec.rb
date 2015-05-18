require 'spec_helper'

describe '`Opal.hash`' do
  it 'converts object literals to hashes' do
    `Opal.hash({a: 1, b: 2})`.should == {a: 1, b: 2}
  end
end

describe 'javascript calls using recv.$meth' do
  it 'should call javascript method' do
    "a1234b5678c".$indexOf('c').should == 10
    "a1234b5678c".$replace(/[0-9]/g, '').should == 'abc'
    "a1234b5678c".$replace(/[0-9]/g, '').$toUpperCase.should == 'ABC'
  end
end
