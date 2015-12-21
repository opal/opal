require 'spec_helper'
require 'js'

describe 'javascript operations using JS module' do
  it 'JS.typeof uses typeof to return underlying javascript type' do
    [1, `null`, `undefined`, Object.new, [], ""].each do |v|
      JS.typeof(v).should == `typeof #{v}`
    end
  end

  it 'JS.new uses new to create new instance' do
    f = `function(){}`
    f.JS[:prototype].JS[:color] = 'black'
    JS.new(f).JS[:color].should == 'black'
  end

  it 'JS.new handles blocks' do
    f = `function(a){this.a = a}`
    JS.new(f){1}.JS.a.should == 1
  end

  it 'JS.instanceof uses instanceof to check if value is an instance of a function' do
    f = `function(){}`
    JS.instanceof(JS.new(f), f).should == true
    JS.instanceof(JS.new(f), `function(){}`).should == false
  end

  it 'JS.delete uses delete to remove properties from objects' do
    f = `{a:1}`
    f.JS[:a].should == 1
    JS.delete(f, :a)
    `#{f.JS[:a]} === undefined`.should == true
  end

  it 'JS.in uses in to check for properties in objects' do
    f = `{a:1}`
    JS.in(:a, f).should == true
    JS.in(:b, f).should == false
  end

  it 'JS.void returns undefined' do
    f = 1
    `#{JS.void(f += 1)} === undefined`.should == true
    f.should == 2
  end

  it 'JS.call calls global javascript methods' do
    JS.call(:parseFloat, '1.0').should == 1
    JS.call(:parseInt, '1').should == 1
    JS.call(:eval, "({a:1})").JS[:a].should == 1
  end

  it 'JS.method_missing calls global javascript methods' do
    JS.parseFloat('1.0').should == 1
    JS.parseInt('1').should == 1
  end

  it 'JS.call calls global javascript methods with blocks' do
    begin
      JS.global.JS[:_test_global_function] = lambda{|pr| pr.call + 1}
      JS._test_global_function{1}.should == 2
    ensure
      JS.delete(JS.global, :_test_global_function)
    end
  end
end
