require 'native'
require 'date'

describe Date do
  describe '#to_n' do
    it 'returns native JS date object' do
      date = Date.new(1984, 1, 24)
      native = date.to_n
      expect(`#{native}.toDateString()`).to eq 'Tue Jan 24 1984'
    end
  end
end
