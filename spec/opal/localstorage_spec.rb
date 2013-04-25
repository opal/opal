require "spec_helper"

describe LocalStorage do
  before do
    LocalStorage.clear
  end

  describe '.[]' do
    it 'returns nil when accessing an undefined value' do
      LocalStorage['woosh'].should be_nil
    end

    it 'returns an empty string when set value was also ""' do
      LocalStorage['empty'] = ''
      LocalStorage['empty'].should == ''
    end
  end

  describe '.[]=' do
    it 'sets values in the localstorage' do
      LocalStorage['foo'] = 'Hello World'
      LocalStorage['foo'].should == 'Hello World'
    end

    it 'stores all values as strings' do
      LocalStorage['foo'] = 3.142
      LocalStorage['foo'].should be_kind_of(String)
    end
  end

  describe '.clear' do
    it 'removes all values from the store' do
      LocalStorage['foo'] = 'wow'
      LocalStorage['bar'] = 'pow'
      LocalStorage.clear
      LocalStorage['foo'].should be_nil
      LocalStorage['bar'].should be_nil
    end
  end

  describe '.delete' do
    it 'deletes the given key from localstorage' do
      LocalStorage['deletable'] = 'Hey there'
      LocalStorage.delete 'deletable'
      LocalStorage['deletable'].should be_nil
    end

    it 'returns the deleted value' do
      LocalStorage['deletable'] = 'Hey there'
      LocalStorage.delete('deletable').should == 'Hey there'
    end
  end
end
