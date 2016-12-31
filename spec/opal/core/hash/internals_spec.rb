describe 'Hash' do

  describe 'internal implementation of string keys' do
    before :each do
      @h = {'a' => 123, 'b' => 456}
    end

    it 'stores keys directly as strings in the `keys` array' do
      `#@h.$$keys.length`.should == 2
      `#@h.$$keys[0]`.should == 'a'
      `#@h.$$keys[1]`.should == 'b'

      @h['c'] = 789

      `#@h.$$keys.length`.should == 3
      `#@h.$$keys[2]`.should == 'c'
    end

    it 'stores values directly as objects in the `smap` object by their corresponding string key' do
      `Object.keys(#@h.$$smap).length`.should == 2
      `#@h.$$smap['a']`.should == 123
      `#@h.$$smap['b']`.should == 456

      @h['c'] = 789

      `Object.keys(#@h.$$smap).length`.should == 3
      `#@h.$$smap['c']`.should == 789
    end

    it 'does not use the `map` object' do
      `Object.keys(#@h.$$map).length`.should == 0

      @h['c'] = 789

      `Object.keys(#@h.$$map).length`.should == 0
    end

    it 'uses the `map` object when an object key is added' do
      `Object.keys(#@h.$$map).length`.should == 0

      @h[Object.new] = 789

      `Object.keys(#@h.$$map).length`.should == 1
    end
  end

  describe 'internal implementation of object keys' do
    before :each do
      @obj1 = Object.new
      @obj2 = Object.new
      @h = {@obj1 => 123, @obj2 => 456}
    end

    it 'uses a data structure called "bucket", which is a wrapper object with `key`, `key_hash`, `value`, and `next` properties' do
      bucket = `#@h.$$keys[0]`
      `#{bucket}.key`.should == @obj1
      `#{bucket}.key_hash`.should == @obj1.hash
      `#{bucket}.value`.should == 123
      `#{bucket}.next === undefined`.should == true
    end

    it 'stores keys in the `keys` array as "bucket" objects' do
      `#@h.$$keys.length`.should == 2
      `#@h.$$keys[0].key`.should == @obj1
      `#@h.$$keys[1].key`.should == @obj2

      obj3 = Object.new
      @h[obj3] = 789

      `#@h.$$keys.length`.should == 3
      `#@h.$$keys[2].key`.should == obj3
    end

    it 'stores values in the `map` object as "bucket" objects by #hash string of their corresponding object key' do
      `Object.keys(#@h.$$map).length`.should == 2
      `#@h.$$map[#{@obj1.hash}].value`.should == 123
      `#@h.$$map[#{@obj2.hash}].value`.should == 456

      obj3 = Object.new
      @h[obj3] = 789

      `Object.keys(#@h.$$map).length`.should == 3
      `#@h.$$map[#{obj3.hash}].value`.should == 789
    end

    it 'keeps a pointer to the same "bucket" object in the `keys` array and in the `map` object' do
      `#@h.$$map[#{@obj1.hash}] === #@h.$$keys[0]`.should == true
      `#@h.$$map[#{@obj2.hash}] === #@h.$$keys[1]`.should == true
    end

    it 'does not use the `smap` object' do
      `Object.keys(#@h.$$smap).length`.should == 0

      @h[Object.new] = 789

      `Object.keys(#@h.$$smap).length`.should == 0
    end

    it 'uses the `smap` object when a string key is added' do
      `Object.keys(#@h.$$smap).length`.should == 0

      @h['c'] = 789

      `Object.keys(#@h.$$smap).length`.should == 1
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

      `Object.keys(#@hash.$$map).length`.should == 0
      `#@hash.$$keys.length`.should == 0

      @hash[@mock1] = 123
      `Object.keys(#@hash.$$map).length`.should == 1
      `#@hash.$$keys.length`.should == 1
      `#@hash.$$keys[0] === #@hash.$$map['hhh']`.should == true
      `#@hash.$$keys[0].key`.should == @mock1
      `#@hash.$$keys[0].key_hash`.should == @mock1.hash
      `#@hash.$$keys[0].value`.should == 123
      `#@hash.$$keys[0].next === undefined`.should == true

      @hash[@mock2] = 456
      `Object.keys(#@hash.$$map).length`.should == 1
      `#@hash.$$keys.length`.should == 2
      `#@hash.$$keys[1] === #@hash.$$map['hhh'].next`.should == true
      `#@hash.$$keys[1].key`.should == @mock2
      `#@hash.$$keys[1].key_hash`.should == @mock2.hash
      `#@hash.$$keys[1].value`.should == 456
      `#@hash.$$keys[1].next === undefined`.should == true

      @hash[@mock3] = 789
      `Object.keys(#@hash.$$map).length`.should == 1
      `#@hash.$$keys.length`.should == 3
      `#@hash.$$keys[2] === #@hash.$$map['hhh'].next.next`.should == true
      `#@hash.$$keys[2].key`.should == @mock3
      `#@hash.$$keys[2].key_hash`.should == @mock3.hash
      `#@hash.$$keys[2].value`.should == 789
      `#@hash.$$keys[2].next === undefined`.should == true

      obj = Object.new
      @hash[obj] = 999
      `Object.keys(#@hash.$$map).length`.should == 2
      `#@hash.$$keys.length`.should == 4
      `#@hash.$$keys[3] === #@hash.$$map[#{obj.hash}]`.should == true
      `#@hash.$$keys[3].key`.should == obj
      `#@hash.$$keys[3].key_hash`.should == obj.hash
      `#@hash.$$keys[3].value`.should == 999
      `#@hash.$$keys[3].next === undefined`.should == true
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

      `Opal.hasOwnProperty.call(#@hash.$$map, 'hhh')`.should == true
      `Opal.hasOwnProperty.call(#@hash.$$map, #{@obj1.hash})`.should == true
      `Opal.hasOwnProperty.call(#@hash.$$smap, 'a')`.should == true
      `Opal.hasOwnProperty.call(#@hash.$$smap, 'b')`.should == true
      `Opal.hasOwnProperty.call(#@hash.$$smap, 'c')`.should == true

      `#@hash.$$keys.length`.should == 8
      `Object.keys(#@hash.$$map).length`.should == 2
      `Object.keys(#@hash.$$smap).length`.should == 3

      `#@hash.$$keys[0].key`.should == @mock1
      `#@hash.$$keys[1]`.should == 'a'
      `#@hash.$$keys[2].key`.should == @mock2
      `#@hash.$$keys[3]`.should == 'b'
      `#@hash.$$keys[4].key`.should == @mock3
      `#@hash.$$keys[5].key`.should == @mock4
      `#@hash.$$keys[6]`.should == 'c'
      `#@hash.$$keys[7].key`.should == @obj1

      `#@hash.$$map['hhh'] === #@hash.$$keys[0]`.should == true
      `#@hash.$$keys[0].next === #@hash.$$keys[2]`.should == true
      `#@hash.$$keys[2].next === #@hash.$$keys[4]`.should == true
      `#@hash.$$keys[4].next === #@hash.$$keys[5]`.should == true
      `#@hash.$$keys[5].next === undefined`.should == true

      @hash.delete @mock2

      `#@hash.$$keys.length`.should == 7
      `Object.keys(#@hash.$$map).length`.should == 2
      `Object.keys(#@hash.$$smap).length`.should == 3

      `#@hash.$$keys[0].key`.should == @mock1
      `#@hash.$$keys[1]`.should == 'a'
      `#@hash.$$keys[2]`.should == 'b'
      `#@hash.$$keys[3].key`.should == @mock3
      `#@hash.$$keys[4].key`.should == @mock4
      `#@hash.$$keys[5]`.should == 'c'
      `#@hash.$$keys[6].key`.should == @obj1

      `#@hash.$$map['hhh'] === #@hash.$$keys[0]`.should == true
      `#@hash.$$keys[0].next === #@hash.$$keys[3]`.should == true
      `#@hash.$$keys[3].next === #@hash.$$keys[4]`.should == true
      `#@hash.$$keys[4].next === undefined`.should == true

      @hash.delete @mock4

      `#@hash.$$keys.length`.should == 6
      `Object.keys(#@hash.$$map).length`.should == 2
      `Object.keys(#@hash.$$smap).length`.should == 3

      `#@hash.$$keys[0].key`.should == @mock1
      `#@hash.$$keys[1]`.should == 'a'
      `#@hash.$$keys[2]`.should == 'b'
      `#@hash.$$keys[3].key`.should == @mock3
      `#@hash.$$keys[4]`.should == 'c'
      `#@hash.$$keys[5].key`.should == @obj1

      `#@hash.$$map['hhh'] === #@hash.$$keys[0]`.should == true
      `#@hash.$$keys[0].next === #@hash.$$keys[3]`.should == true
      `#@hash.$$keys[3].next === undefined`.should == true

      @hash.delete @mock1

      `#@hash.$$keys.length`.should == 5
      `Object.keys(#@hash.$$map).length`.should == 2
      `Object.keys(#@hash.$$smap).length`.should == 3

      `#@hash.$$keys[0]`.should == 'a'
      `#@hash.$$keys[1]`.should == 'b'
      `#@hash.$$keys[2].key`.should == @mock3
      `#@hash.$$keys[3]`.should == 'c'
      `#@hash.$$keys[4].key`.should == @obj1

      `#@hash.$$map['hhh'] === #@hash.$$keys[2]`.should == true
      `#@hash.$$keys[2].next === undefined`.should == true

      @hash.delete @mock3

      `#@hash.$$keys.length`.should == 4
      `Object.keys(#@hash.$$map).length`.should == 1
      `Object.keys(#@hash.$$smap).length`.should == 3

      `#@hash.$$keys[0]`.should == 'a'
      `#@hash.$$keys[1]`.should == 'b'
      `#@hash.$$keys[2]`.should == 'c'
      `#@hash.$$keys[3].key`.should == @obj1

      `#@hash.$$map['hhh'] === undefined`.should == true

      @hash.delete @obj1

      `#@hash.$$keys.length`.should == 3
      `Object.keys(#@hash.$$map).length`.should == 0
      `Object.keys(#@hash.$$smap).length`.should == 3

      `#@hash.$$keys[0]`.should == 'a'
      `#@hash.$$keys[1]`.should == 'b'
      `#@hash.$$keys[2]`.should == 'c'

      `#@hash.$$map[#{@obj1.hash}] === undefined`.should == true

      @hash.delete 'b'

      `#@hash.$$keys.length`.should == 2
      `Object.keys(#@hash.$$map).length`.should == 0
      `Object.keys(#@hash.$$smap).length`.should == 2

      `#@hash.$$keys[0]`.should == 'a'
      `#@hash.$$keys[1]`.should == 'c'
      `#@hash.$$smap['a']`.should == 'abc'
      `#@hash.$$smap['b'] === undefined`.should == true
      `#@hash.$$smap['c']`.should == 'ghi'

      @hash.delete 'c'

      `#@hash.$$keys.length`.should == 1
      `Object.keys(#@hash.$$map).length`.should == 0
      `Object.keys(#@hash.$$smap).length`.should == 1

      `#@hash.$$keys[0]`.should == 'a'
      `#@hash.$$smap['a']`.should == 'abc'
      `#@hash.$$smap['b'] === undefined`.should == true
      `#@hash.$$smap['c'] === undefined`.should == true

      @hash.delete 'a'

      `#@hash.$$keys.length`.should == 0
      `Object.keys(#@hash.$$map).length`.should == 0
      `Object.keys(#@hash.$$smap).length`.should == 0

      `#@hash.$$smap['a'] === undefined`.should == true
      `#@hash.$$smap['b'] === undefined`.should == true
      `#@hash.$$smap['c'] === undefined`.should == true

      `Opal.hasOwnProperty.call(#@hash.$$map, 'hhh')`.should == false
      `Opal.hasOwnProperty.call(#@hash.$$map, #{@obj1.hash})`.should == false
      `Opal.hasOwnProperty.call(#@hash.$$smap, 'a')`.should == false
      `Opal.hasOwnProperty.call(#@hash.$$smap, 'b')`.should == false
      `Opal.hasOwnProperty.call(#@hash.$$smap, 'c')`.should == false
    end
  end
end
