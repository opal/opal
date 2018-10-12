require 'spec_helper'

describe 'Iterable props defined by Opal on core JS objects' do
  %x{
    function iterableKeysOf(obj) {
      var result = [];

      for (var key in obj) {
        result.push(key);
      }

      return result;
    }
  }

  it 'is empty for numbers' do
    `iterableKeysOf(1)`.should == []
  end

  it 'is empty for strings' do
    `iterableKeysOf('123')`.should == ['0', '1', '2'] # indexes, in JS they are iterable by default
    `iterableKeysOf(new String('123'))`.should == ['0', '1', '2'] # indexes, in JS they are iterable by default
  end

  it 'is empty for plain objects' do
    `iterableKeysOf({})`.should == []
  end

  it 'is empty for boolean' do
    `iterableKeysOf(true)`.should == []
    `iterableKeysOf(false)`.should == []
  end

  it 'is empty for regexp' do
    `iterableKeysOf(/regexp/)`.should == []
  end

  it 'is empty for functions' do
    `iterableKeysOf(function() {})`.should == []
  end

  it 'is empty for dates' do
    `iterableKeysOf(new Date())`.should == []
  end

  it 'is empty for errors' do
    `iterableKeysOf(new Error('message'))`.should == []
  end

  it 'is empty for Math' do
    `iterableKeysOf(Math)`.should == []
  end
end
