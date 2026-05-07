# frozen_string_literal: true

# backtick_javascript: true

# rubocop:disable Style/GlobalVars,Lint/Void,Style/NilComparison,Style/WordArray

require 'spec_helper'
require 'opal/js'

describe 'Opal::JS' do
  before do
    `Opal.global.__opal_js_spec = {}`
  end

  after do
    `delete Opal.global.__opal_js_spec`
  end

  it 'installs $js as the wrapped global object' do
    $js.should be_kind_of(Opal::JS::Object)
    `#{$js.instance_variable_get(:@native)} === Opal.global`.should == true
  end

  it 'wraps JS objects, arrays, and functions' do
    Opal::JS.wrap(`{a: 1}`).should be_kind_of(Opal::JS::Object)
    Opal::JS.wrap(`[1, 2]`).should be_kind_of(Opal::JS::Array)
    Opal::JS.wrap(`function(){}`).should be_kind_of(Opal::JS::Function)
  end

  it 'exposes JS object/native predicate helpers' do
    Opal::JS.object?(`{}`).should == true
    Opal::JS.object?(Object.new).should == false

    Opal::JS.native?(`{}`).should == true
    Opal::JS.native?(nil).should == true
    Opal::JS.native?(Object.new).should == false
  end

  it 'caches wrappers for repeated JS object and function wrapping' do
    $js[:__opal_js_spec] = `{
      fn: function() { return 1; }
    }`

    $js[:__opal_js_spec].equal?($js[:__opal_js_spec]).should == true
    $js.__opal_js_spec[:fn].equal?($js.__opal_js_spec[:fn]).should == true
  end

  it 'caches wrappers for repeated JS promise wrapping' do
    promise = `Promise.resolve(1)`

    Opal::JS.wrap(promise).equal?(Opal::JS.wrap(promise)).should == true
  end

  it 'wraps typed array-like objects as live arrays' do
    wrapper = Opal::JS.wrap(`new Uint8Array([1, 2])`)

    wrapper.should be_kind_of(Opal::JS::Array)
    wrapper.to_a.should == [1, 2]
  end

  it 'structurally wraps length-bearing JS objects as live arrays' do
    wrapper = Opal::JS.wrap(`{0: 'a', 1: 'b', length: 2, name: 'box'}`)

    wrapper.should be_kind_of(Opal::JS::Array)
    wrapper.to_a.should == ['a', 'b']
    wrapper[:name].should == 'box'
  end

  it 'deep-converts explicit JS object and array snapshots' do
    object = Opal::JS.wrap(`{ nested: { value: 1 }, list: [2] }`)
    array = Opal::JS.wrap(`[{ value: 3 }]`)

    object.to_h.should == { 'nested' => { 'value' => 1 }, 'list' => [2] }
    array.to_a.should == [{ 'value' => 3 }]
  end

  it 'uses exact bracket access without raising for missing properties' do
    $js[:__opal_js_spec][:missing].should == nil
  end

  it 'returns nil for missing dynamic getters' do
    $js.__opal_js_spec.missing.should == nil
  end

  it 'raises for missing dynamic calls with arguments' do
    -> { $js.__opal_js_spec.missing(1) }.should raise_error(NoMethodError)
  end

  it 'creates new JS properties through dynamic setters' do
    $js.__opal_js_spec.new_key = 42

    $js[:__opal_js_spec][:newKey].should == 42
    $js.__opal_js_spec.new_key.should == 42
  end

  it 'converts Ruby nil to JS undefined' do
    $js[:__opal_js_spec][:value] = nil
    `typeof Opal.global.__opal_js_spec.value`.should == 'undefined'
  end

  it 'converts Ruby hashes to plain JS objects without key translation' do
    $js[:__opal_js_spec][:value] = { abc: 123, abc_def: 456, 7 => 8 }

    `Opal.global.__opal_js_spec.value instanceof Map`.should == false
    `Opal.global.__opal_js_spec.value.abc`.should == 123
    `Opal.global.__opal_js_spec.value.abc_def`.should == 456
    `Opal.global.__opal_js_spec.value[7]`.should == 8
  end

  it 'raises ConversionError for unsupported hash keys' do
    -> { $js[:__opal_js_spec][:value] = { Object.new => 1 } }.should raise_error(Opal::JS::ConversionError)
  end

  it 'raises ConversionError for cyclic Ruby hash and array conversion' do
    hash = {}
    hash[:self] = hash

    array = []
    array << array

    -> { $js[:__opal_js_spec][:value] = hash }.should raise_error(Opal::JS::ConversionError)
    -> { $js[:__opal_js_spec][:value] = array }.should raise_error(Opal::JS::ConversionError)
  end

  it 'raises ConversionError for cyclic JS object and array snapshots' do
    object = Opal::JS.wrap(`(function() { var object = {}; object.self = object; return object; })()`)
    array = Opal::JS.wrap(`(function() { var array = []; array[0] = array; return array; })()`)

    -> { object.to_h }.should raise_error(Opal::JS::ConversionError)
    -> { array.to_a }.should raise_error(Opal::JS::ConversionError)
  end

  it 'prefers exact JS names and supports canonical snake_case translation' do
    $js[:__opal_js_spec] = `{
      querySelectorAll: function(selector) { return selector + ':translated'; },
      query_selector_all: function(selector) { return selector + ':exact'; }
    }`

    $js.__opal_js_spec.query_selector_all('h1').should == 'h1:exact'
    $js.__opal_js_spec.querySelectorAll('h2').should == 'h2:translated'

    `delete Opal.global.__opal_js_spec.query_selector_all`
    $js.__opal_js_spec.query_selector_all('h3').should == 'h3:translated'
  end

  it 'auto-calls zero-argument dynamic functions except constructor/prototype/uppercase names' do
    $js[:__opal_js_spec] = `{
      reload: function() { return 'reloaded'; },
      constructor: function() { return 'constructed'; },
      HTMLElement: function() { return 'element'; }
    }`

    $js.__opal_js_spec.reload.should == 'reloaded'
    $js.__opal_js_spec.constructor.should be_kind_of(Opal::JS::Function)
    $js.__opal_js_spec.HTMLElement.should be_kind_of(Opal::JS::Function)
  end

  it 'returns receiver-bound functions from bracket access' do
    $js[:__opal_js_spec] = `{
      value: 41,
      add: function(amount) { return this.value + amount; }
    }`

    $js.__opal_js_spec[:add].call(1).should == 42
  end

  it 'exposes public call, new, and instanceof? helpers' do
    $js[:__opal_js_spec] = `{
      value: 41,
      add: function(amount) { return this.value + amount; },
      Klass: function(value) { this.value = value; }
    }`

    object = $js.__opal_js_spec
    instance = Opal::JS.new(object.Klass, 42)

    Opal::JS.call(object, :add, 1).should == 42
    instance[:value].should == 42
    Opal::JS.instanceof?(instance, object.Klass).should == true
  end

  it 'exposes JS this synchronously during callbacks while preserving Ruby block self' do
    $js[:__opal_js_spec] = `{
      value: 42,
      callBlock: function(block) { return block.call(this); }
    }`

    ruby_self = self
    seen_self = nil
    seen_this = nil

    $js.__opal_js_spec.call_block do
      seen_self = self
      seen_this = Opal::JS.this[:value]
    end

    seen_self.should == ruby_self
    seen_this.should == 42
  end
end

# rubocop:enable Style/GlobalVars,Lint/Void,Style/NilComparison,Style/WordArray
