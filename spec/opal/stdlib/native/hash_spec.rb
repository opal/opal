require 'native'

describe Hash do
  it 'turns a native JS object into a hash' do
    obj = %x{
      {
        a: 1,
        b: "two",
        c: {
          d: 1,
        },
        e: [
          {
            f: 'g',
          },
        ],
      }
    }

    h = Hash.new(obj)
    expected_hash = {
      a: 1,
      b: "two",
      c: {
        d: 1,
      },
      e: [
        {
          f: 'g',
        },
      ],
    }

    expect(h).to eq(expected_hash)
  end

  describe '#to_n' do
    it 'converts a hash with native objects as values' do
      obj = { 'a_key' => `{ key: 1 }` }
      native = obj.to_n
      `#{native}.a_key.key`.should == 1
    end
  end
end
