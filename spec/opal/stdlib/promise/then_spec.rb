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
  
  it 'works with multiple values' do
    x = 42
    Promise.values(1,2,3).then { |a, b, c| x = a+b+c }
    x.should == 6
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
  
  it 'can use multiple values in a returned promise' do
    a = Promise.new

    x = 42
        
    a.then { |v0| Promise.values(1,2,3,v0) }.then { |v1, v2, v3, v4| x = v1+v2+v3+v4 }
      
    a.resolve(4)
      
    x.should == 10
  end
      
  it 'sends raised exceptions as rejections' do
    x = nil

    Promise.value(2).then { raise "hue" }.rescue { |v| x = v }

    x.should be_kind_of(RuntimeError)
  end

  it 'sends raised exceptions inside rescue blocks as next errors' do
    x = nil

    Promise.value(2).then { raise "hue" }.rescue { raise "omg" }.rescue { |v| x = v }

    x.should be_kind_of(RuntimeError)
  end

  it 'raises an exception when the promise has already been chained' do
    p = Promise.value(2)
    p.then {}

    proc {
      p.then {}
    }.should raise_error(ArgumentError)
  end
end
