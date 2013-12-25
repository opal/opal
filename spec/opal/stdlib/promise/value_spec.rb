require 'promise'

describe 'Promise.value' do
  it 'resolves the promise with the given value' do
    Promise.value(23).value.should == 23
  end

  it 'marks the promise as realized' do
    Promise.value(23).realized?.should be_true
  end

  it 'marks the promise as resolved' do
    Promise.value(23).resolved?.should be_true
  end
end
