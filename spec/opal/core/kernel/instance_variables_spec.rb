describe "Kernel#instance_variables" do
  context 'for nil' do
    it 'returns blank array' do
      expect(nil.instance_variables).to eq([])
    end
  end

  context 'for string' do
    it 'returns blank array' do
      expect(''.instance_variables).to eq([])
    end
  end

  context 'for hash' do
    it 'returns blank array' do
      expect({}.instance_variables).to eq([])
    end
  end

  context 'for object' do
    it 'returns blank array' do
      expect(Object.new.instance_variables).to eq([])
    end
  end
end
