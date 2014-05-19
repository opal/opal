require 'promise'

describe 'Promise.error' do
  it 'rejects the promise with the given error' do
    expect(Promise.error(23).error).to eq(23)
  end

  it 'marks the promise as realized' do
    expect(Promise.error(23).realized?).to be_true
  end

  it 'marks the promise as rejected' do
    expect(Promise.error(23).rejected?).to be_true
  end
end
