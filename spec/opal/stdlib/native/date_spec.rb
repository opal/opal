require 'native'
require 'date'

describe Date do
  describe '#to_n' do
    it 'returns native JS date object' do
      date = Date.new(1984, 1, 24)
      native = date.to_n
      expect(`#{native}.toISOString()`).to eq '1984-01-24T00:00:00.000Z'
    end
  end
end
