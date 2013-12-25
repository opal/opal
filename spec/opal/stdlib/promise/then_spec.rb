require 'promise'

describe 'Promise#then' do
  it 'calls the block when the promise has already been resolved' do
    x = 42
    Promise.value(23).then { |v| x = v }
    x.should == 23
  end

  it 'calls the block when the promise is resolved' do
    a = Promise.new
    x = 42

    a.then { |v| x = v }
    a.resolve(23)

    x.should == 23
  end

  it 'works with multiple chains' do
    x = 42
    Promise.value(2).then { |v| v * 2 }.then { |v| v * 4 }.then { |v| x = v }
    x.should == 16
  end

  it 'works when a block returns a promise' do
    a = Promise.new
    b = Promise.new

    x = 42
    a.then { b }.then { |v| x = v }

    a.resolve(42)
    b.resolve(23)

    x.should == 23
  end
end
