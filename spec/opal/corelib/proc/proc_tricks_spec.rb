describe 'Proc' do
  describe '#new' do
    it 'is not a lambda' do
      Proc.new {}.lambda?.should == false
    end
  end
end