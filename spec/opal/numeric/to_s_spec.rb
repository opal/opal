describe 'Numeric#to_s' do
  it 'converts to a string representation' do
    0.to_s.should == '0'
    1.to_s.should == '1'
    9.to_s.should == '9'
    10.to_s.should == '10'
  end

  it 'converts to different radices' do
    10.to_s(10).should == '10'

    1.to_s(2).should == '1'
    2.to_s(2).should == '10'
    10.to_s(2).should == '1010'

    1.to_s(16).should == '1'
    10.to_s(16).should == 'a'
    15.to_s(16).should == 'f'
    16.to_s(16).should == '10'

    35.to_s(36).should == 'z'
    36.to_s(36).should == '10'
  end
end
