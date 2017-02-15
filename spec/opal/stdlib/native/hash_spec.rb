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
            h: [null],
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
          h: [nil],
        },
      ],
    }

    expect(h).to eq(expected_hash)
  end

  it 'turns Object.create(null) JS objects into a hash' do
    %x{
      var obj = Object.create(null);
      var foo = Object.create(null);
      var bar = Object.create(null);
      obj.foo = foo;
      foo.bar = bar;
      bar.baz = 'baz';
    }
    hash = Hash.new(`obj`)

    expect(hash).to eq({ foo: { bar: { baz: 'baz' } } })
  end

  describe '#to_n' do
    it 'converts a hash with native objects as values' do
      obj = { 'a_key' => `{ key: 1 }` }
      native = obj.to_n
      `#{native}.a_key.key`.should == 1
    end

    it 'passes Ruby objects that cannot be converted' do
      object = Object.new
      hash = { foo: object }
      native = hash.to_n
      expect(`#{native}.foo`).to eq object
    end
  end
end
