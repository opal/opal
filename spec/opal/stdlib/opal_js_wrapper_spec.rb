# frozen_string_literal: true

# backtick_javascript: true

# rubocop:disable Style/GlobalVars,Lint/Void,Style/SymbolArray,Style/WordArray,Layout/MultilineMethodCallBraceLayout

require 'spec_helper'
require 'opal/js'

`function OpalJSSpecAnimal(name) { this.name = name; }`
`OpalJSSpecAnimal.prototype.kind = function() { return 'animal:' + this.name; }`
`OpalJSSpecAnimal.prototype.describeArgs = function() { return Array.prototype.slice.call(arguments); }`
`OpalJSSpecAnimal.prototype.configure = function(options) { return options; }`
`OpalJSSpecAnimal.prototype.renamedValue = 'initial'`
`Opal.global.OpalJSSpecAnimal = OpalJSSpecAnimal`

`function OpalJSSpecDog(name) { OpalJSSpecAnimal.call(this, name); }`
`OpalJSSpecDog.prototype = Object.create(OpalJSSpecAnimal.prototype)`
`OpalJSSpecDog.prototype.constructor = OpalJSSpecDog`
`Opal.global.OpalJSSpecDog = OpalJSSpecDog`

`function OpalJSSpecBear(name) { OpalJSSpecAnimal.call(this, name); }`
`OpalJSSpecBear.prototype = Object.create(OpalJSSpecAnimal.prototype)`
`OpalJSSpecBear.prototype.constructor = OpalJSSpecBear`
`Opal.global.OpalJSSpecBear = OpalJSSpecBear`

`Opal.global.__opal_js_animal = new OpalJSSpecAnimal('a')`
`Opal.global.__opal_js_dog = new OpalJSSpecDog('d')`
`Opal.global.__opal_js_bear = new OpalJSSpecBear('b')`
`Opal.global.__opal_js_entity = { name: 'e' }`

module OpalJSSpecTimerEvents
  include Opal::JS::Wrapper

  js_method :set_timeout, 'setTimeout', args: [:&, :*]
end

class OpalJSSpecAnimalWrapper
  include Opal::JS::Wrapper

  js_object
  js_constructor $js[:OpalJSSpecAnimal]
  js_method :swap, 'describeArgs', args: [1, 0, 2]
  js_method :last_first, 'describeArgs', args: [-1, :*]
  js_method :remaining_then_last, 'describeArgs', args: [:*, -1]
  js_method :remaining_then_first, 'describeArgs', args: [:*, 0]
  js_method :configure_raw, 'configure', args: [:**]
  js_method :configure_converted, 'configure', args: [:**], kwargs: :convert
  js_accessor :renamed, 'renamedValue'
end

class OpalJSSpecDogWrapper < OpalJSSpecAnimalWrapper
  js_constructor $js[:OpalJSSpecDog]
end

class OpalJSSpecRootWrapper
  include OpalJSSpecTimerEvents
  include Opal::JS::Wrapper

  js_object
end

`function OpalJSSpecLate(value) { this.value = value; }`
`Opal.global.OpalJSSpecLate = OpalJSSpecLate`

class OpalJSSpecLateWrapper
  include Opal::JS::Wrapper

  js_object
end

describe 'Opal::JS::Wrapper DSL' do
  it 'wraps existing values and constructs through js_constructor' do
    animal = OpalJSSpecAnimalWrapper.wrap($js[:__opal_js_animal])
    created = OpalJSSpecAnimalWrapper.new('created')

    animal.kind.should == 'animal:a'
    created.kind.should == 'animal:created'
  end

  it 'uses registered constructors to pick specific wrapper classes' do
    $js[:__opal_js_entity].should be_kind_of(Opal::JS::Object)
    $js[:__opal_js_animal].should be_kind_of(OpalJSSpecAnimalWrapper)
    $js[:__opal_js_dog].should be_kind_of(OpalJSSpecDogWrapper)
    $js[:__opal_js_bear].should be_kind_of(OpalJSSpecAnimalWrapper)
  end

  it 'keeps cached wrappers stable after late wrapper registration' do
    raw_before = `new OpalJSSpecLate(1)`
    raw_after = `new OpalJSSpecLate(2)`
    before = Opal::JS.wrap(raw_before)

    OpalJSSpecLateWrapper.js_register_wrapper $js[:OpalJSSpecLate]

    Opal::JS.wrap(raw_before).should == before
    Opal::JS.wrap(raw_before).should be_kind_of(Opal::JS::Object)
    Opal::JS.wrap(raw_after).should be_kind_of(OpalJSSpecLateWrapper)
  end

  it 'does not validate explicit wrap class against the JS constructor' do
    OpalJSSpecDogWrapper.wrap($js[:__opal_js_animal]).should be_kind_of(OpalJSSpecDogWrapper)
  end

  it 'rejects rebinding an initialized wrapper' do
    wrapper = OpalJSSpecAnimalWrapper.wrap($js[:__opal_js_animal])

    -> { wrapper.initialize_wrapped($js[:__opal_js_dog]) }.should raise_error(ArgumentError)
  end

  it 'supports js_method argument projection' do
    wrapper = OpalJSSpecAnimalWrapper.wrap($js[:__opal_js_animal])

    wrapper.swap('a', 'b', 'c').to_a.should == ['b', 'a', 'c']
    wrapper.last_first('a', 'b', 'c').to_a.should == ['c', 'a', 'b']
    wrapper.remaining_then_last('a', 'b', 'c').to_a.should == ['a', 'b', 'c']
    wrapper.remaining_then_first('a', 'b', 'c').to_a.should == ['b', 'c', 'a']
  end

  it 'strictly requires args projection for blocks and kwargs' do
    wrapper = OpalJSSpecAnimalWrapper.wrap($js[:__opal_js_animal])

    -> { wrapper.swap('a') }.should raise_error(ArgumentError)
    -> { wrapper.swap('a', 'b', 'c') {} }.should raise_error(ArgumentError)
    -> { wrapper.swap('a', 'b', 'c', option: true) }.should raise_error(ArgumentError)
  end

  it 'positions kwargs and converts keys only when requested' do
    wrapper = OpalJSSpecAnimalWrapper.wrap($js[:__opal_js_animal])

    raw = wrapper.configure_raw(background_color: 'red')
    converted = wrapper.configure_converted(background_color: 'blue')

    raw[:background_color].should == 'red'
    converted[:backgroundColor].should == 'blue'
  end

  it 'supports js_accessor aliases' do
    wrapper = OpalJSSpecAnimalWrapper.wrap($js[:__opal_js_animal])

    wrapper.renamed = 'changed'
    wrapper.renamed.should == 'changed'
  end

  it 'supports wrapper DSL declarations from modules included before Wrapper' do
    root = OpalJSSpecRootWrapper.wrap(`{
      setTimeout: function(block, delay) { return block() + ':' + delay; }
    }`)

    root.set_timeout(10) { 'timer' }.should == 'timer:10'
  end

  it 'supports array-like mutators and exact dig' do
    array = Opal::JS.wrap(`[1, 2]`)
    object = Opal::JS.wrap(`{ nested: { value: 3 } }`)

    array.push(3).should == array
    array << 4
    array.pop.should == 4
    array.shift.should == 1
    array.unshift(0).should == array
    array.to_a.should == [0, 2, 3]
    object.dig(:nested, :value).should == 3
  end
end

# rubocop:enable Style/GlobalVars,Lint/Void,Style/SymbolArray,Style/WordArray,Layout/MultilineMethodCallBraceLayout
