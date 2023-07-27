# backtick_javascript: true

describe 'Hash' do

  describe 'internal implementation of string keys' do
    before :each do
      @h = {'a' => 123, 'b' => 456}
    end

    it 'stores keys directly as strings in the `Map`' do
      `#@h.size`.should == 2
      `Array.from(#@h.keys())[0]`.should == 'a'
      `Array.from(#@h.keys())[1]`.should == 'b'

      @h['c'] = 789

      `#@h.size`.should == 3
      `Array.from(#@h.keys())[2]`.should == 'c'
    end

    it 'stores values directly as objects in the `Map`' do
      `Array.from(#@h.values()).length`.should == 2
      `Array.from(#@h.values())[0]`.should == 123
      `Array.from(#@h.values())[1]`.should == 456

      @h['c'] = 789

      `Array.from(#@h.values()).length`.should == 3
      `Array.from(#@h.values())[2]`.should == 789
    end

    it 'does not use the `Map.$$keys`' do
      `(#@h.$$keys === undefined)`.should == true

      @h['c'] = 789

      `(#@h.$$keys === undefined)`.should == true
    end

    it 'uses the `Map.$$keys` object when an object key is added' do
      `(#@h.$$keys === undefined)`.should == true

      @h[Object.new] = 789

      `#@h.$$keys.size`.should == 1
    end

    it 'converts string objects to values when used to delete keys' do
      h = {'a' => 'a'}
      k = String.new(h.keys.first)
      h.delete(k)
      h.should == {}
    end
  end

  describe 'internal implementation of object keys' do
    before :each do
      @obj1 = Object.new
      @obj2 = Object.new
      @h = {@obj1 => 123, @obj2 => 456}
    end

    it 'uses a `Map.$$keys` to keep references of objects to be used as keys' do
      keys = `Array.from(#@h.$$keys.entries())`
      `#{keys}[0][1][0]`.should == @obj1
      `#{keys}[0][0]`.should == @obj1.hash
    end

    it 'allows multiple keys that #hash to the same value to be stored in the Hash' do
      @hash = {}

      @mock1 = mock('mock1')
      @mock1.should_receive(:hash).at_least(1).and_return('hhh')
      @mock1.should_receive(:eql?).exactly(0)

      @mock2 = mock('mock2')
      @mock2.should_receive(:hash).at_least(1).and_return('hhh')
      @mock2.should_receive(:eql?).exactly(1).and_return(false)

      @mock3 = mock('mock3')
      @mock3.should_receive(:hash).at_least(1).and_return('hhh')
      @mock3.should_receive(:eql?).exactly(2).and_return(false)

      `#@hash.size`.should == 0
      `(#@hash.$$keys === undefined)`.should == true

      @hash[@mock1] = 123
      `#@hash.$$keys.size`.should == 1
      keys = `Array.from(#@hash.$$keys.entries())`
      `#{keys}[0][1].length`.should == 1
      `#{keys}[0][1][0]`.should == @mock1
      `#{keys}[0][0]`.should == @mock1.hash
      `#@hash.get(#@mock1)`.should == 123

      @hash[@mock2] = 456
      `#@hash.$$keys.size`.should == 1
      keys = `Array.from(#@hash.$$keys.entries())`
      `#{keys}[0][1].length`.should == 2
      `#{keys}[0][1][1]`.should == @mock2
      `#{keys}[0][0]`.should == @mock2.hash
      `#@hash.get(#@mock2)`.should == 456

      @hash[@mock3] = 789
      `#@hash.$$keys.size`.should == 1
      keys = `Array.from(#@hash.$$keys.entries())`
      `#{keys}[0][1].length`.should == 3
      `#{keys}[0][1][2]`.should == @mock3
      `#{keys}[0][0]`.should == @mock3.hash
      `#@hash.get(#@mock3)`.should == 789

      obj = Object.new
      @hash[obj] = 999
      `#@hash.$$keys.size`.should == 2
      keys = `Array.from(#@hash.$$keys.entries())`
      `#{keys}[1][1].length`.should == 1
      `#{keys}[1][1][0]`.should == obj
      `#{keys}[1][0]`.should == obj.hash
      `#@hash.get(#{obj})`.should == 999
    end

    it 'correctly updates internal data structures when deleting keys' do
      @mock1 = mock('mock1')
      @mock1.should_receive(:hash).any_number_of_times.and_return('hhh')
      @mock1.should_receive(:eql?).any_number_of_times.and_return(false)

      @mock2 = mock('mock2')
      @mock2.should_receive(:hash).any_number_of_times.and_return('hhh')
      @mock2.should_receive(:eql?).any_number_of_times.and_return(false)

      @mock3 = mock('mock3')
      @mock3.should_receive(:hash).any_number_of_times.and_return('hhh')
      @mock3.should_receive(:eql?).any_number_of_times.and_return(false)

      @mock4 = mock('mock4')
      @mock4.should_receive(:hash).any_number_of_times.and_return('hhh')
      @mock4.should_receive(:eql?).any_number_of_times.and_return(false)

      @hash = {
        @mock1 => 123,
        'a'    => 'abc',
        @mock2 => 456,
        'b'    => 'def',
        @mock3 => 789,
        @mock4 => 999,
        'c'    => 'ghi',
        @obj1  => 'xyz'
      }

      `#@hash.$$keys.has('hhh')`.should == true
      `#@hash.$$keys.has(#{@obj1.hash})`.should == true
      `#@hash.has('a')`.should == true
      `#@hash.has('b')`.should == true
      `#@hash.has('c')`.should == true

      `#@hash.size`.should == 8
      `#@hash.$$keys.size`.should == 2

      keys = `Array.from(#@hash.keys())`
      keys[0].should == @mock1
      keys[1].should == 'a'
      keys[2].should == @mock2
      keys[3].should == 'b'
      keys[4].should == @mock3
      keys[5].should == @mock4
      keys[6].should == 'c'
      keys[7].should == @obj1

      keys = `Array.from(#@hash.$$keys.values())[0]`
      `#{keys}.length`.should == 4
      keys[0].should == @mock1
      keys[1].should == @mock2
      keys[2].should == @mock3
      keys[3].should == @mock4
      keys = `Array.from(#@hash.$$keys.values())[1]`
      `#{keys}.length`.should == 1
      keys[0].should == @obj1

      @hash.delete @mock2

      `#@hash.size`.should == 7
      keys = `Array.from(#@hash.$$keys.values())[0]`
      `#{keys}.length`.should == 3
      keys[0].should == @mock1
      keys[1].should == @mock3
      keys[2].should == @mock4

      keys = `Array.from(#@hash.keys())`
      keys[0].should == @mock1
      keys[1].should == 'a'
      keys[2].should == 'b'
      keys[3].should == @mock3
      keys[4].should == @mock4
      keys[5].should == 'c'
      keys[6].should == @obj1

      @hash.delete @mock4

      `#@hash.size`.should == 6
      keys = `Array.from(#@hash.$$keys.values())[0]`
      `#{keys}.length`.should == 2
      keys[0].should == @mock1
      keys[1].should == @mock3

      keys = `Array.from(#@hash.keys())`
      keys[0].should == @mock1
      keys[1].should == 'a'
      keys[2].should == 'b'
      keys[3].should == @mock3
      keys[4].should == 'c'
      keys[5].should == @obj1

      @hash.delete @mock1

      `#@hash.size`.should == 5
      keys = `Array.from(#@hash.$$keys.values())[0]`
      `#{keys}.length`.should == 1
      keys[0].should == @mock3

      keys = `Array.from(#@hash.keys())`
      keys[0].should == 'a'
      keys[1].should == 'b'
      keys[2].should == @mock3
      keys[3].should == 'c'
      keys[4].should == @obj1

      @hash.delete @mock3

      `#@hash.size`.should == 4
      `#@hash.$$keys.size`.should == 1
      keys = `Array.from(#@hash.$$keys.values())[0]`
      `#{keys}.length`.should == 1
      keys[0].should == @obj1

      keys = `Array.from(#@hash.keys())`
      keys[0].should == 'a'
      keys[1].should == 'b'
      keys[2].should == 'c'
      keys[3].should == @obj1

      @hash.delete @obj1

      `#@hash.size`.should == 3
      `#@hash.$$keys.size`.should == 0

      keys = `Array.from(#@hash.keys())`
      keys[0].should == 'a'
      keys[1].should == 'b'
      keys[2].should == 'c'

      `#@hash.$$keys.get(#{@obj1.hash}) === undefined`.should == true

      @hash.delete 'b'

      `#@hash.size`.should == 2
      `#@hash.$$keys.size`.should == 0

      keys = `Array.from(#@hash.keys())`
      keys[0].should == 'a'
      keys[1].should == 'c'

      `#@hash.get('a')`.should == 'abc'
      `#@hash.get('b') === undefined`.should == true
      `#@hash.get('c')`.should == 'ghi'

      @hash.delete 'c'

      `#@hash.size`.should == 1
      `#@hash.$$keys.size`.should == 0

      keys = `Array.from(#@hash.keys())`
      keys[0].should == 'a'

      `#@hash.get('a')`.should == 'abc'
      `#@hash.get('b') === undefined`.should == true
      `#@hash.get('c') === undefined`.should == true

      @hash.delete 'a'

      `#@hash.size`.should == 0
      `#@hash.$$keys.size`.should == 0

      `#@hash.get('a') === undefined`.should == true
      `#@hash.get('b') === undefined`.should == true
      `#@hash.get('c') === undefined`.should == true
    end
  end
end
