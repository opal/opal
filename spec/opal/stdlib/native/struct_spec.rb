require 'native'

describe Struct do
  describe '#to_n' do
    it 'converts a struct with native attributes to a JS object' do
      klass = Struct.new(:attribute)
      obj = klass.new(`{ key: 1 }`)
      native = obj.to_n
      `#{native}.attribute.key`.should == 1
    end
  end
end
