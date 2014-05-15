require 'promise'

describe 'Promise#rescue' do
  it 'calls the block when the promise has already been rejected' do
    x = 42
    Promise.error(23).rescue { |v| x = v }
    expect(x).to eq(23)
  end

  it 'calls the block when the promise is rejected' do
    a = Promise.new
    x = 42

    a.rescue { |v| x = v }
    a.reject(23)

    expect(x).to eq(23)
  end

  it 'does not call then blocks when the promise is rejected' do
    x = 42
    y = 23

    Promise.error(23).then { y = 42 }.rescue { |v| x = v }

    expect(x).to eq(23)
    expect(y).to eq(23)
  end

  it 'does not call subsequent rescue blocks' do
    x = 42
    Promise.error(23).rescue { |v| x = v }.rescue { x = 42 }
    expect(x).to eq(23)
  end
end
