require 'promise'

describe 'Promise#collect' do
  it 'calls the block with all the previous results' do
    x = 42

    Promise.value(1).then { 2 }.then { 3 }.collect {|a, b, c|
      x = a + b + c
    }

    x.should == 6
  end

  it 'calls the then after the collect' do
    x = 42

    Promise.value(1).then { 2 }.then { 3 }.collect {|a, b, c|
      a + b + c
    }.then { |v| x = v }

    x.should == 6
  end

  it 'works after a when' do
    x = 42

    Promise.value(1).then {
      Promise.when Promise.value(2), Promise.value(3)
    }.collect {|a, b|
      x = a + b[0] + b[1]
    }

    x.should == 6
  end
end
