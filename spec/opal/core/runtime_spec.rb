require 'spec_helper'

describe '`Opal.hash`' do
  it 'converts object literals to hashes' do
    `Opal.hash({a: 1, b: 2})`.should == {a: 1, b: 2}
  end
end

# describe 'Opal.ancestors' do
#   M1 = Module.new
#   M2 = Module.new
#   M3 = Module.new
#   M4 = Module.new
#   M5 = Module.new
#   M1.send :include, M2
#   M1.send :prepend, M5
#   C1 = Class.new
#   C1.prepend M1
#   C1.prepend M2
#   C1.include M5
#   C2 = Class.new(C1)
#   C2.include M3
#   C2.include M4
#   it 'returns a list of ancestors' do
#     `Opal.ancestors(#{M1})`.should == [M5, M1, M2]
#     `Opal.ancestors(#{C1})`.should == [M5, M1, M2, C1, Object, MSpecRSpecAdapter, Kernel, BasicObject]
#     `Opal.ancestors(#{C2})`.should == [C2, M4, M3, M5, M1, M2, C1, Object, MSpecRSpecAdapter, Kernel, BasicObject]
#   end
# end

describe 'javascript access using .JS' do
  it 'should call javascript methods via .JS.method()' do
    "a1234b5678c".JS.indexOf('c').should == 10
    "a1234b5678c".JS.replace(`/[0-9]/g`, '').should == 'abc'
  end

  it 'should call javascript methods via .JS.method arg' do
    ("a1234b5678c".JS.indexOf 'c').should == 10
    ("a1234b5678c".JS.replace `/[0-9]/g`, '').should == 'abc'
  end

  it 'should call javascript methods with blocks via .JS.method' do
    f = `{a:function(f){return f(1) + f(2)}}`
    f.JS.a{|v| v*2}.should == 6
    v = f.JS.a do |v| v*2 end
    v.should == 6
  end

  it 'should call javascript methods with args and blocks via .JS.method' do
    f = `{a:function(a, f){return f(a, 1) + f(a, 2)}}`
    f.JS.a(3){|b, v| b+v*2}.should == 12
    v = f.JS.a 3 do |b, v| b+v*2 end
    v.should == 12
  end

  it 'should support javascript properties via .JS[]' do
    "a1234b5678c".JS['length'].should == 11
    `{a:1}`.JS['a'].should == 1
    `{a:1}`.JS['a'].should == 1
    [2, 4].JS[0].should == 2
    [2, 4].JS[1].should == 4
    [2, 4].JS[:length].should == 2
  end

  it 'should be chainable' do
    "a1234b5678c".JS.replace(`/[0-9]/g`, '').JS.toUpperCase.should == 'ABC'
    "a1234b5678c".JS.replace(`/[0-9]/g`, '').JS[:length].should == 3
    "a1234b5678c".JS[:length].JS.toString.should == "11"
    `{a:{b:1}}`.JS[:a].JS[:b].JS.toString.should == '1'
    f = `{a:function(f){return {b: function(f2){return f(f2(1)) + f(f2(2))}}}}`
    f.JS.a{|v| v*2}.JS.b{|v| v*3}.should == 18
  end

  it 'should set javascript properties via .JS[arg] = rhs' do
    a = `{}`
    a.JS[:foo] = 1
    a.JS[:foo].should == 1
    `a["foo"]`.should == 1
  end
end
