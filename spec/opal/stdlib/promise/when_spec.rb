require 'promise'

describe 'Promise.when' do
  it 'calls the block with all promises results' do
    a = Promise.new
    b = Promise.new

    x = 42

    Promise.when(a, b).then {|y, z|
      x = y + z
    }

    a.resolve(1)
    b.resolve(2)

    x.should == 3
  end
end
