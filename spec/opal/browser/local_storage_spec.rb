require 'spec_helper'
require 'browser/local_storage'

describe Browser::LocalStorage do
  before do
    @storage = Browser::LocalStorage
    @storage.clear
  end

  describe '.[]' do
    it 'returns nil when accessing an undefined value' do
      @storage['woosh'].should be_nil
    end

    it 'returns an empty string when set value was also ""' do
      @storage['empty'] = ''
      @storage['empty'].should == ''
    end
  end

  describe '.[]=' do
    it 'sets values in the localstorage' do
      @storage['foo'] = 'Hello World'
      @storage['foo'].should == 'Hello World'
    end

    it 'stores all values as strings' do
      @storage['foo'] = 3.142
      @storage['foo'].should be_kind_of(String)
    end
  end

  describe '.clear' do
    it 'removes all values from the store' do
      @storage['foo'] = 'wow'
      @storage['bar'] = 'pow'
      @storage.clear
      @storage['foo'].should be_nil
      @storage['bar'].should be_nil
    end
  end

  describe '.delete' do
    it 'deletes the given key from localstorage' do
      @storage['deletable'] = 'Hey there'
      @storage.delete 'deletable'
      @storage['deletable'].should be_nil
    end

    it 'returns the deleted value' do
      @storage['deletable'] = 'Hey there'
      @storage.delete('deletable').should == 'Hey there'
    end
  end
end
