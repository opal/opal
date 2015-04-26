require 'promise'

describe 'Promise#always' do
  it 'calls the block when it was resolved' do
    x = 42
    Promise.value(23).then { |v| x = v }.always { |v| x = 2 }
    x.should == 2
  end

  it 'calls the block when it was rejected' do
    x = 42
    Promise.error(23).rescue { |v| x = v }.always { |v| x = 2 }
    x.should == 2
  end

  it 'acts as resolved' do
    x = 42
    Promise.error(23).rescue { |v| x = v }.always { x = 2 }.then { x = 3 }
    x.should == 3
  end

  it 'raises an exception when the promise has already been chained' do
    p = Promise.value(2)
    p.then {}

    proc {
      p.always {}
    }.should raise_error(ArgumentError)
  end
end
