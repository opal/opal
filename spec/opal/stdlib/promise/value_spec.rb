require 'promise'

describe 'Promise.value' do
  it 'resolves the promise with the given value' do
    expect(Promise.value(23).value).to eq(23)
  end

  it 'marks the promise as realized' do
    expect(Promise.value(23).realized?).to be_true
  end

  it 'marks the promise as resolved' do
    expect(Promise.value(23).resolved?).to be_true
  end
end
