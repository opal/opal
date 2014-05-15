describe 'Proc' do
  describe '#new' do
    it 'is not a lambda' do
      expect(Proc.new {}.lambda?).to eq(false)
    end
  end
end