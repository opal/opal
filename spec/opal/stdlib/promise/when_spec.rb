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

    expect(x).to eq(3)
  end

  it 'can be built lazily' do
    a = Promise.new
    b = Promise.value(3)

    x = 42

    Promise.when(a).and(b).then {|c, d|
      x = c + d
    }

    a.resolve(2)

    expect(x).to eq(5)
  end
end
