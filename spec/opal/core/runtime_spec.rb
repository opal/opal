require 'spec_helper'

describe '`Opal.hash`' do
  it 'converts object literals to hashes' do
    `Opal.hash({a: 1, b: 2})`.should == {a: 1, b: 2}
  end
end

describe 'javascript access using .JS' do
  it 'should call javascript methods via .JS.method()' do
    "a1234b5678c".JS.indexOf('c').should == 10
    "a1234b5678c".JS.replace(/[0-9]/g, '').should == 'abc'
  end

  it 'should retrieve javascript properites via .JS.prop' do
    "a1234b5678c".JS.length.should == 11
    `{a:1}`.JS.a.should == 1
  end

  it 'should support javascript arefs via .JS[]' do
    `{a:1}`.JS['a'].should == 1
    [2, 4].JS[0].should == 2
    [2, 4].JS[1].should == 4
  end

  it 'should be chainable' do
    "a1234b5678c".JS.replace(/[0-9]/g, '').JS.toUpperCase().should == 'ABC'
    "a1234b5678c".JS.replace(/[0-9]/g, '').JS.length.should == 3
    "a1234b5678c".JS.length.JS.toString().should == "11"
    `{a:{b:1}}`.JS[:a].JS[:b].JS.toString().should == '1'
  end
end
