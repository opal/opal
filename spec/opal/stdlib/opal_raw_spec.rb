# backtick_javascript: true

require 'spec_helper'
require 'opal/raw'

describe 'javascript operations using Opal::Raw module' do
  it 'Opal::Raw.typeof uses typeof to return underlying javascript type' do
    [1, `null`, `undefined`, Object.new, [], ""].each do |v|
      Opal::Raw.typeof(v).should == `typeof #{v}`
    end
  end

  it 'Opal::Raw.new uses new to create new instance' do
    f = `function(){}`
    f.JS[:prototype].JS[:color] = 'black'
    Opal::Raw.new(f).JS[:color].should == 'black'
  end

  it 'Opal::Raw.new handles blocks' do
    f = `function(a){this.a = a}`
    Opal::Raw.new(f){1}.JS.a.should == 1
  end

  it 'Opal::Raw.instanceof uses instanceof to check if value is an instance of a function' do
    f = `function(){}`
    Opal::Raw.instanceof(Opal::Raw.new(f), f).should == true
    Opal::Raw.instanceof(Opal::Raw.new(f), `function(){}`).should == false
  end

  it 'Opal::Raw.delete uses delete to remove properties from objects' do
    f = `{a:1}`
    f.JS[:a].should == 1
    Opal::Raw.delete(f, :a)
    `#{f.JS[:a]} === undefined`.should == true
  end

  it 'Opal::Raw.in uses in to check for properties in objects' do
    f = `{a:1}`
    Opal::Raw.in(:a, f).should == true
    Opal::Raw.in(:b, f).should == false
  end

  it 'Opal::Raw.void returns undefined' do
    f = 1
    `#{Opal::Raw.void(f += 1)} === undefined`.should == true
    f.should == 2
  end

  it 'Opal::Raw.call calls global javascript methods' do
    Opal::Raw.call(:parseFloat, '1.0').should == 1
    Opal::Raw.call(:parseInt, '1').should == 1
    Opal::Raw.call(:eval, "({a:1})").JS[:a].should == 1
  end

  it 'Opal::Raw.method_missing calls global javascript methods' do
    Opal::Raw.parseFloat('1.0').should == 1
    Opal::Raw.parseInt('1').should == 1
  end

  it 'Opal::Raw.call calls global javascript methods with blocks' do
    begin
      Opal::Raw.global.JS[:_test_global_function] = lambda{|pr| pr.call + 1}
      Opal::Raw._test_global_function{1}.should == 2
    ensure
      Opal::Raw.delete(Opal::Raw.global, :_test_global_function)
    end
  end

  it 'JS.<METHOD> supports complex method calls' do
    obj = `{ foo: function(){return "foo"} }`
    args = [1,2,3]
    obj.JS.foo(*args).should == :foo
  end

  it 'JS.<METHOD> supports block arguments with self' do
    # We want to ensure, that there's no "x" argument present
    obj = `{ foo: function(arg, block, x) { block(arg, x); } }`
    z = nil
    obj.JS.foo(123) { |arg,x| z = [self, arg, x] }
    # And also we want to ensure that self is not garbled
    z.should == [self, 123, nil]
  end
end
