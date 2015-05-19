require 'spec_helper'

describe '`Opal.hash`' do
  it 'converts object literals to hashes' do
    `Opal.hash({a: 1, b: 2})`.should == {a: 1, b: 2}
  end
end

describe 'javascript calls using recv.JS.meth' do
  it 'should call javascript method' do
    "a1234b5678c".JS.indexOf('c').should == 10
    "a1234b5678c".JS.replace(/[0-9]/g, '').should == 'abc'
    "a1234b5678c".JS.replace(/[0-9]/g, '').JS.toUpperCase.should == 'ABC'
  end
end
