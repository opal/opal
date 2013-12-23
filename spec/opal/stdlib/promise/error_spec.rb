require 'promise'

describe 'Promise.error' do
  it 'rejects the promise with the given error' do
    Promise.error(23).error.should == 23
  end

  it 'marks the promise as realized' do
    Promise.error(23).realized?.should be_true
  end

  it 'marks the promise as rejected' do
    Promise.error(23).rejected?.should be_true
  end
end
