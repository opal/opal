require 'native'

describe Array do
  describe '#to_n' do
    it 'converts an array with native objects to a JS array' do
      obj = [`{ key: 1 }`]
      native = obj.to_n
      `#{native}[0].key`.should == 1
    end
  end
end
