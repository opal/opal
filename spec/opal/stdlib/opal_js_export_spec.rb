# frozen_string_literal: true

# backtick_javascript: true

# rubocop:disable Lint/Void,Performance/RedundantBlockCall,Style/TrivialAccessors,Lint/UselessAssignment

require 'spec_helper'
require 'opal/js'

class OpalJSSpecExport
  OPAL_JS_SPEC_CONST = 123

  attr_accessor :my_property

  def initialize(value = nil, options = nil, &block)
    @value = value
    @options = options
    @block_value = block.call if block
  end

  def value
    @value
  end

  def options
    @options
  end

  def block_value
    @block_value
  end

  def convert(text)
    "converted #{text}"
  end

  def self.call(value)
    "called #{value}"
  end

  def self.promise
    PromiseV2.resolve({ abc: 123 })
  end

  def self.invoke(callable, value)
    callable.call(value)
  end

  def self.invoke_with_default(callable)
    callable.call('final member')
  end

  def self.same_object?(left, right)
    left.equal?(right)
  end

  def self.raw_shape(*args, **kwargs, &block)
    [args, kwargs, block&.call]
  end

  def self.empty?
    true
  end
end

class OpalJSSpecKwargsExport
  def kwargs_value(**kwargs)
    kwargs
  end

  def receive(value)
    value
  end
end

describe 'Opal.$' do
  it 'exports Ruby constants, constructs classes, dispatches methods, and assigns setters' do
    `Opal.global.__opal_export_spec = new Opal.$.OpalJSSpecExport(7, {argOne: 3}, function() { return 'block'; })`

    `Opal.global.__opal_export_spec.value()`.should == 7
    `Opal.global.__opal_export_spec.options().arg_one`.should == 3
    `Opal.global.__opal_export_spec.blockValue()`.should == 'block'
    `Opal.global.__opal_export_spec.convert('text')`.should == 'converted text'

    `Opal.global.__opal_export_spec.myProperty = true`
    `Opal.global.__opal_export_spec.myProperty()`.should == true

    `delete Opal.global.__opal_export_spec`
  end

  it 'hides then on non-Promise facades' do
    `Opal.$.OpalJSSpecExport.then === undefined`.should == true
    `('then' in Opal.$.OpalJSSpecExport)`.should == false
    `Object.keys(Opal.$.OpalJSSpecExport).indexOf('then')`.should == -1
  end

  it 'allows direct class facade call to fall back to Ruby call when supported' do
    `Opal.$.OpalJSSpecExport('value')`.should == 'called value'
  end

  it 'passes final plain object arguments as keyword hashes' do
    `Opal.global.__opal_export_spec = new Opal.$.OpalJSSpecKwargsExport()`
    `Opal.global.__opal_export_spec.kwargsValue({argOne: 3}).arg_one`.should == 3
    `delete Opal.global.__opal_export_spec`
  end

  it 'raises ConversionError for cyclic JS argument conversion' do
    `Opal.global.__opal_export_spec = new Opal.$.OpalJSSpecKwargsExport()`
    `Opal.global.__opal_export_cycle_object = {}; Opal.global.__opal_export_cycle_object.self = Opal.global.__opal_export_cycle_object`
    `Opal.global.__opal_export_cycle_array = []; Opal.global.__opal_export_cycle_array[0] = Opal.global.__opal_export_cycle_array`

    -> { `Opal.global.__opal_export_spec.receive(Opal.global.__opal_export_cycle_object)` }.should raise_error(Opal::JS::ConversionError)
    -> { `Opal.global.__opal_export_spec.receive(Opal.global.__opal_export_cycle_array)` }.should raise_error(Opal::JS::ConversionError)

    `delete Opal.global.__opal_export_cycle_object`
    `delete Opal.global.__opal_export_cycle_array`
    `delete Opal.global.__opal_export_spec`
  end

  it 'returns PromiseV2 values as JS promises resolving to JS-friendly values' do
    `Opal.global.__opal_export_promise = Opal.$.OpalJSSpecExport.promise()`

    `Opal.global.__opal_export_promise instanceof Promise`.should == true
    `typeof Opal.global.__opal_export_promise.then`.should == 'function'

    `delete Opal.global.__opal_export_promise`
  end

  it 'supports __send__ as the exact method escape' do
    `Opal.$.OpalJSSpecExport.__send__('call', 'raw')`.should == 'called raw'
  end

  it 'supports __send_raw__ with explicit args, kwargs, and block' do
    result = `Opal.$.OpalJSSpecExport.__send_raw__('raw_shape', [1, function() { return 'arg'; }], {kwarg: 123, kwargs3: 233}, function() { return 'block'; })`

    `result[0][0]`.should == 1
    `result[0][1].call()`.should == 'arg'
    `result[1].kwarg`.should == 123
    `result[1].kwargs3`.should == 233
    `result[2]`.should == 'block'
  end

  it 'keeps JS function identity when converting explicit positional args to Ruby' do
    `Opal.global.__opal_export_fn = function() { return 'same'; }`

    `Opal.$.OpalJSSpecExport.__send_raw__('same_object?', [Opal.global.__opal_export_fn, Opal.global.__opal_export_fn])`.should == true

    `delete Opal.global.__opal_export_fn`
  end

  it 'supports __send_raw__ with only an explicit block' do
    result = `Opal.$.OpalJSSpecExport.__send_raw__('raw_shape', function() { return 'block'; })`

    `result[0].length`.should == 0
    `Object.keys(result[1]).length`.should == 0
    `result[2]`.should == 'block'
  end

  it 'supports __send_raw__ with kwargs and no positional args' do
    result = `Opal.$.OpalJSSpecExport.__send_raw__('raw_shape', {argOne: 1})`

    `result[0].length`.should == 0
    `result[1].arg_one`.should == 1
    `result[2] === null || result[2] === undefined`.should == true
  end

  it 'converts exported member facades back to Ruby callable objects' do
    `Opal.$.OpalJSSpecExport.invoke(Opal.$.OpalJSSpecExport.call, 'member')`.should == 'called member'
    `Opal.$.OpalJSSpecExport.invokeWithDefault(Opal.$.OpalJSSpecExport.call)`.should == 'called final member'
  end

  it 'supports instanceof through Symbol.hasInstance' do
    `Opal.global.__opal_export_spec = new Opal.$.OpalJSSpecExport()`
    `Opal.global.__opal_export_spec instanceof Opal.$.OpalJSSpecExport`.should == true
    `delete Opal.global.__opal_export_spec`
  end

  it 'enumerates JS-facing method names and constants without hiding punctuation methods' do
    `Object.keys(Opal.$.OpalJSSpecExport).indexOf('call') >= 0`.should == true
    `Object.keys(Opal.$.OpalJSSpecExport).indexOf('rawShape') >= 0`.should == true
    `Object.keys(Opal.$.OpalJSSpecExport).indexOf('raw_shape')`.should == -1
    `('rawShape' in Opal.$.OpalJSSpecExport)`.should == true
    `('raw_shape' in Opal.$.OpalJSSpecExport)`.should == false
    `Object.getOwnPropertyDescriptor(Opal.$.OpalJSSpecExport, 'rawShape') !== undefined`.should == true
    `Object.getOwnPropertyDescriptor(Opal.$.OpalJSSpecExport, 'raw_shape') === undefined`.should == true
    `Object.keys(Opal.$.OpalJSSpecExport).indexOf('empty?') >= 0`.should == true
    `Object.keys(Opal.$.OpalJSSpecExport).indexOf('OPAL_JS_SPEC_CONST') >= 0`.should == true
    `('OPAL_JS_SPEC_CONST' in Opal.$.OpalJSSpecExport)`.should == true
  end
end

# rubocop:enable Lint/Void,Performance/RedundantBlockCall,Style/TrivialAccessors,Lint/UselessAssignment
