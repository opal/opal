describe 'Hash#has_value?' do
  context 'when hash contains provided value' do
    it 'returns true' do
      expect({ a: 1 }.has_value?(1)).to eq(true)
    end
  end

  context 'when hash does not contain provided value' do
    it 'returns false' do
      expect({ a: 1 }.has_value?(2)).to eq(false)
    end
  end
end
