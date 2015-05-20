require 'spec_helper'

describe '`Opal.hash`' do
  it 'converts object literals to hashes' do
    `Opal.hash({a: 1, b: 2})`.should == {a: 1, b: 2}
  end
end

describe 'direct javascript method calls using :js_prefix compiler option' do
  def eval_rb(ruby_code, js_prefix = true)
    compiler = Opal::Compiler.new(ruby_code, :js_prefix=>js_prefix)
    compiler.compile
    js = compiler.result
    `eval(js)`
  end
  it 'should call javascript method' do
    eval_rb('"a1234b5678c".JS.indexOf("c")').should == 10
    eval_rb('"a1234b5678c".JS.replace(/[0-9]/g, "")').should == 'abc'
    eval_rb('"a1234b5678c".JS.replace(/[0-9]/g, "").JS.toUpperCase').should == 'ABC'
    eval_rb('"a1234b5678c".js_replace(/[0-9]/g, "").js_toUpperCase', 'js_').should == 'ABC'
  end
end
