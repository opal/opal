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
end
