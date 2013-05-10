class Array < `Array`
  include Enumerable

  # Mark all javascript arrays as being valid ruby arrays
  `def._isArray = true`

  def self.[](*objects)
    objects
  end

  def self.new(size = undefined, obj = nil, &block)
    %x{
      var arr = [];

      if (size && size._isArray) {
        for (var i = 0; i < size.length; i++) {
          arr[i] = size[i];
        }
      }
      else {
        if (block === nil) {
          for (var i = 0; i < size; i++) {
            arr[i] = obj;
          }
        }
        else {
          for (var i = 0; i < size; i++) {
            arr[i] = block(i);
          }
        }
      }

      return arr;
    }
  end

  def self.try_convert(obj)
    %x{
      if (obj._isArray) {
        return obj;
      }

      return nil;
    }
  end

  def &(other)
    %x{
      var result = [],
          seen   = {};

      for (var i = 0, length = #{self}.length; i < length; i++) {
        var item = #{self}[i];

        if (!seen[item]) {
          for (var j = 0, length2 = other.length; j < length2; j++) {
            var item2 = other[j];

            if ((item === item2) && !seen[item]) {
              seen[item] = true;

              result.push(item);
            }
          }
        }
      }

      return result;
    }
  end

  def *(other)
    %x{
      if (typeof(other) === 'string') {
        return #{self}.join(other);
      }

      var result = [];

      for (var i = 0; i < other; i++) {
        result = result.concat(#{self});
      }

      return result;
    }
  end

  def +(other)
    `#{self}.concat(other)`
  end

  def -(other)
    %x{
      var a = #{self},
          b = #{other},
          tmp = [],
          result = [];
      
     if (typeof(b) == "object" && !(b instanceof Array))  {
        if (b['$to_ary'] && typeof(b['$to_ary']) == "function") {
          b = b['$to_ary']();
        } else {
          #{raise TypeError.new("can't convert to Array. Array#-") };
        }
      }else if ((typeof(b) != "object")) {
        #{raise TypeError.new("can't convert to Array. Array#-") }; 
      }      

      if (a.length == 0)
        return [];
      if (b.length == 0)
        return a;    
          
      for(var i = 0, length = b.length; i < length; i++) { 
        tmp[b[i]] = true;
      }
      for(var i = 0, length = a.length; i < length; i++) {
        if (!tmp[a[i]]) { 
          result.push(a[i]);
        }  
     }
     
      return result; 
    }
    
    #p other.to_ary
    #reject { |i| other.include? i }
  end

  def <<(object)
    `#{self}.push(object);`

    self
  end

  def <=>(other)
    %x{
      if (#{self.hash} === #{other.hash}) {
        return 0;
      }

      if (#{self}.length != other.length) {
        return (#{self}.length > other.length) ? 1 : -1;
      }

      for (var i = 0, length = #{self}.length, tmp; i < length; i++) {
        if ((tmp = #{`#{self}[i]` <=> `other[i]`}) !== 0) {
          return tmp;
        }
      }

      return 0;
    }
  end

  def ==(other)
    %x{
      if (!other || (#{self}.length !== other.length)) {
        return false;
      }

      for (var i = 0, length = #{self}.length, tmp1, tmp2; i < length; i++) {
        tmp1 = #{self}[i];
        tmp2 = #{other}[i];
        
        //recursive
        if ((typeof(tmp1.indexOf) == "function") &&
            (typeof(tmp2.indexOf) == "function") &&  
            (tmp1.indexOf(tmp2) == tmp2.indexOf(tmp1))) {
          if (tmp1.indexOf(tmp1) == tmp2.indexOf(tmp2)) {
            continue;
          }
        }
        
        if (!#{`#{self}[i]` == `other[i]`}) {
          return false;
        }
        
      }
      

      return true;
    }
  end

  def [](index, length = undefined)
    %x{
      var size = #{self}.length;

      if (typeof index !== 'number') {
        if (index._isRange) {
          var exclude = index.exclude;
          length      = index.end;
          index       = index.begin;

          if (index > size) {
            return nil;
          }

          if (length < 0) {
            length += size;
          }

          if (!exclude) length += 1;
          return #{self}.slice(index, length);
        }
        else {
          #{ raise "bad arg for Array#[]" };
        }
      }

      if (index < 0) {
        index += size;
      }

      if (length !== undefined) {
        if (length < 0 || index > size || index < 0) {
          return nil;
        }

        return #{self}.slice(index, index + length);
      }
      else {
        if (index >= size || index < 0) {
          return nil;
        }

        return #{self}[index];
      }
    }
  end

  def []=(index, value)
    %x{
      var size = #{self}.length;

      if (index < 0) {
        index += size;
      }

      return #{self}[index] = value;
    }
  end

  def assoc(object)
    %x{
      for (var i = 0, length = #{self}.length, item; i < length; i++) {
        if (item = #{self}[i], item.length && #{`item[0]` == object}) {
          return item;
        }
      }

      return nil;
    }
  end

  def at(index)
    %x{
      if (index < 0) {
        index += #{self}.length;
      }

      if (index < 0 || index >= #{self}.length) {
        return nil;
      }

      return #{self}[index];
    }
  end

  def clear
    `#{self}.splice(0, #{self}.length)`

    self
  end

  def clone
    `#{self}.slice()`
  end

  def collect(&block)
    %x{
      var result = [];

      for (var i = 0, length = #{self}.length, value; i < length; i++) {
        if ((value = block(#{self}[i])) === __breaker) {
          return __breaker.$v;
        }

        result.push(value);
      }

      return result;
    }
  end

  def collect!(&block)
    %x{
      for (var i = 0, length = #{self}.length, val; i < length; i++) {
        if ((val = block(#{self}[i])) === __breaker) {
          return __breaker.$v;
        }

        #{self}[i] = val;
      }
    }

    self
  end

  def compact
    %x{
      var result = [];

      for (var i = 0, length = #{self}.length, item; i < length; i++) {
        if ((item = #{self}[i]) !== nil) {
          result.push(item);
        }
      }

      return result;
    }
  end

  def compact!
    %x{
      var original = #{self}.length;

      for (var i = 0, length = #{self}.length; i < length; i++) {
        if (#{self}[i] === nil) {
          #{self}.splice(i, 1);

          length--;
          i--;
        }
      }

      return #{self}.length === original ? nil : #{self};
    }
  end

  def concat(other)
    %x{
      for (var i = 0, length = other.length; i < length; i++) {
        #{self}.push(other[i]);
      }
    }

    self
  end

  def count(object = undefined)
    %x{
      if (object == null) {
        return #{self}.length;
      }

      var result = 0;

      for (var i = 0, length = #{self}.length; i < length; i++) {
        if (#{`#{self}[i]` == object}) {
          result++;
        }
      }

      return result;
    }
  end

  def delete(object)
    %x{
      var original = #{self}.length;

      for (var i = 0, length = original; i < length; i++) {
        if (#{`#{self}[i]` == object}) {
          #{self}.splice(i, 1);

          length--;
          i--;
        }
      }

      return #{self}.length === original ? nil : object;
    }
  end

  def delete_at(index)
    %x{
      if (index < 0) {
        index += #{self}.length;
      }

      if (index < 0 || index >= #{self}.length) {
        return nil;
      }

      var result = #{self}[index];

      #{self}.splice(index, 1);

      return result;
    }
  end

  def delete_if(&block)
    %x{
      for (var i = 0, length = #{self}.length, value; i < length; i++) {
        if ((value = block(#{self}[i])) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          #{self}.splice(i, 1);

          length--;
          i--;
        }
      }
    }

    self
  end

  def drop(number)
    `#{self}.slice(number)`
  end

  alias dup clone

  def each(&block)
    return enum_for :each unless block_given?

    `for (var i = 0, length = #{self}.length; i < length; i++) {`
      yield `#{self}[i]`
    `}`

    self
  end

  def each_index(&block)
    `for (var i = 0, length = #{self}.length; i < length; i++) {`
      yield `i`
    `}`

    self
  end

  def empty?
    `!#{self}.length`
  end

  def fetch(index, defaults = undefined, &block)
    %x{
      var original = index;

      if (index < 0) {
        index += #{self}.length;
      }

      if (index >= 0 && index < #{self}.length) {
        return #{self}[index];
      }

      if (defaults != null) {
        return defaults;
      }

      if (block !== nil) {
        return block(original);
      }

      #{ raise IndexError, "Array#fetch" };
    }
  end

  def fill(obj = undefined, &block)
    %x{
      if (block !== nil) {
        for (var i = 0, length = #{self}.length; i < length; i++) {
          #{self}[i] = block(i);
        }
      }
      else {
        for (var i = 0, length = #{self}.length; i < length; i++) {
          #{self}[i] = obj;
        }
      }
    }

    self
  end

  def first(count = undefined)
    %x{
      if (count != null) {
        return #{self}.slice(0, count);
      }

      return #{self}.length === 0 ? nil : #{self}[0];
    }
  end

  def flatten(level = undefined)
    %x{
      var result = [];

      for (var i = 0, length = #{self}.length, item; i < length; i++) {
        item = #{self}[i];

        if (item._isArray) {
          if (level == null) {
            result = result.concat(#{`item`.flatten});
          }
          else if (level === 0) {
            result.push(item);
          }
          else {
            result = result.concat(#{`item`.flatten(`level - 1`)});
          }
        }
        else {
          result.push(item);
        }
      }

      return result;
    }
  end

  def flatten!(level = undefined)
    %x{
      var size = #{self}.length;
      #{replace flatten level};

      return size === #{self}.length ? nil : #{self};
    }
  end

  def hash
    `#{self}._id || (#{self}._id = Opal.uid())`
  end

  def include?(member)
    %x{
      for (var i = 0, length = #{self}.length; i < length; i++) {
        if (#{`#{self}[i]` == member}) {
          return true;
        }
      }

      return false;
    }
  end

  def index(object=undefined, &block)
    %x{
      if (object != null) {
        for (var i = 0, length = #{self}.length; i < length; i++) {
          if (#{`#{self}[i]` == object}) {
            return i;
          }
        }
      }
      else if (block !== nil) {
        for (var i = 0, length = #{self}.length, value; i < length; i++) {
          if ((value = block(#{self}[i])) === __breaker) {
            return __breaker.$v;
          }

          if (value !== false && value !== nil) {
            return i;
          }
        }
      }

      return nil;
    }
  end

  def insert(index, *objects)
    %x{
      if (objects.length > 0) {
        if (index < 0) {
          index += #{self}.length + 1;

          if (index < 0) {
            #{ raise IndexError, "#{index} is out of bounds" };
          }
        }
        if (index > #{self}.length) {
          for (var i = #{self}.length; i < index; i++) {
            #{self}.push(nil);
          }
        }

        #{self}.splice.apply(#{self}, [index, 0].concat(objects));
      }
    }

    self
  end

  def inspect
    %x{
      var i, inspect, el, el_insp, length, object_id;

      inspect = [];
      object_id = #{object_id};
      length = #{self}.length;

      for (i = 0; i < length; i++) {
        el = #{self[`i`]};

        // Check object_id to ensure it's not the same array get into an infinite loop
        el_insp = #{`el`.object_id} === object_id ? '[...]' : #{`el`.inspect};

        inspect.push(el_insp);
      }
      return '[' + inspect.join(', ') + ']';
    }
  end

  def join(sep = '')
    %x{
      var result = [];

      for (var i = 0, length = #{self}.length; i < length; i++) {
        result.push(#{`#{self}[i]`.to_s});
      }

      return result.join(sep);
    }
  end

  def keep_if(&block)
    %x{
      for (var i = 0, length = #{self}.length, value; i < length; i++) {
        if ((value = block(#{self}[i])) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === nil) {
          #{self}.splice(i, 1);

          length--;
          i--;
        }
      }
    }

    self
  end

  def last(count = undefined)
    %x{
      var length = #{self}.length;
      
      if (count === nil || typeof(count) == 'string') { 
        #{ raise TypeError, "no implicit conversion to integer" };
      }
        
      if (typeof(count) == 'object') {
        if (typeof(count['$to_int']) == 'function') {
          count = count['$to_int']();
        } 
        else {
          #{ raise TypeError, "no implicit conversion to integer" };
        }
      }
      
      if (count == null) {
        return length === 0 ? nil : #{self}[length - 1];
      }
      else if (count < 0) {
        #{ raise ArgumentError, "negative count given" };
      }

      if (count > length) {
        count = length;
      }

      return #{self}.slice(length - count, length);
    }
  end

  def length
    `#{self}.length`
  end

  alias map collect

  alias map! collect!

  def pop(count = undefined)
    %x{
      var length = #{self}.length;

      if (count == null) {
        return length === 0 ? nil : #{self}.pop();
      }

      if (count < 0) {
        #{ raise "negative count given" };
      }

      return count > length ? #{self}.splice(0, #{self}.length) : #{self}.splice(length - count, length);
    }
  end

  def push(*objects)
    %x{
      for (var i = 0, length = objects.length; i < length; i++) {
        #{self}.push(objects[i]);
      }
    }

    self
  end

  def rassoc(object)
    %x{
      for (var i = 0, length = #{self}.length, item; i < length; i++) {
        item = #{self}[i];

        if (item.length && item[1] !== undefined) {
          if (#{`item[1]` == object}) {
            return item;
          }
        }
      }

      return nil;
    }
  end

  def reject(&block)
    %x{
      var result = [];

      for (var i = 0, length = #{self}.length, value; i < length; i++) {
        if ((value = block(#{self}[i])) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === nil) {
          result.push(#{self}[i]);
        }
      }
      return result;
    }
  end

  def reject!(&block)
    %x{
      var original = #{self}.length;
      #{ delete_if &block };
      return #{self}.length === original ? nil : #{self};
    }
  end

  def replace(other)
    %x{
      #{self}.splice(0, #{self}.length);
      #{self}.push.apply(#{self}, other);
      return #{self};
    }
  end

  def reverse
    `#{self}.slice(0).reverse()`
  end

  alias_native :reverse!, :reverse

  def reverse_each(&block)
    reverse.each &block

    self
  end

  def rindex(object = undefined, &block)
    %x{
      if (block !== nil) {
        for (var i = #{self}.length - 1, value; i >= 0; i--) {
          if ((value = block(#{self}[i])) === __breaker) {
            return __breaker.$v;
          }

          if (value !== false && value !== nil) {
            return i;
          }
        }
      }
      else {
        for (var i = #{self}.length - 1; i >= 0; i--) {
          if (#{`#{self}[i]` == `object`}) {
            return i;
          }
        }
      }

      return nil;
    }
  end

  def select(&block)
    %x{
      var result = [];

      for (var i = 0, length = #{self}.length, item, value; i < length; i++) {
        item = #{self}[i];

        if ((value = block(item)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          result.push(item);
        }
      }

      return result;
    }
  end

  def select!(&block)
    %x{
      var original = #{self}.length;
      #{ keep_if &block };
      return #{self}.length === original ? nil : #{self};
    }
  end

  def shift(count = undefined)
    %x{
      if (#{self}.length === 0) {
        return nil;
      }

      return count == null ? #{self}.shift() : #{self}.splice(0, count)
    }
  end

  alias size length

  def shuffle()
    %x{
        for (var i = #{self}.length - 1; i > 0; i--) {
          var j = Math.floor(Math.random() * (i + 1));
          var tmp = #{self}[i];
          #{self}[i] = #{self}[j];
          #{self}[j] = tmp;
        }

        return #{self};
    }
  end

  alias slice :[]

  def slice!(index, length = undefined)
    %x{
      if (index < 0) {
        index += #{self}.length;
      }

      if (length != null) {
        return #{self}.splice(index, length);
      }

      if (index < 0 || index >= #{self}.length) {
        return nil;
      }

      return #{self}.splice(index, 1)[0];
    }
  end

  def sort(&block)
    %x{
      var copy = #{self}.slice();
      var t_arg_error = false;
      var t_break = [];
        
      if (block !== nil) {
        var result = copy.sort(function(x, y) {
          var result = block(x, y);
          if (result === __breaker) {
            t_break.push(__breaker.$v);
          }
          if (result === nil) {
            t_arg_error = true;  
          }
          if (result['$<=>'] && typeof(result['$<=>']) == "function") {
            result = result['$<=>'](0);
          }
          if ([-1, 0, 1].indexOf(result) == -1) {
            t_arg_error = true;
          }
          return result;
        });

        if (t_break.length > 0)
          return t_break[0];
        if (t_arg_error)
          #{raise ArgumentError, "Array#sort"};

        return result;
      }
      
      var result = copy.sort(function(a, b){ 
        if (typeof(a) !== typeof(b)) {
          t_arg_error = true;
        }
        
        if (a['$<=>'] && typeof(a['$<=>']) == "function") {
          var result = a['$<=>'](b);
          if (result === nil) {
            t_arg_error = true;
          } 
          return result; 
        }  
        if (a > b)
          return 1;
        if (a < b)
          return -1;
        return 0;  
      });
      
      if (t_arg_error)
        #{raise ArgumentError, "Array#sort"};

      return result;
    }
  end

  def sort!(&block)
    %x{
      var result;
      if (block !== nil) {
        //strangely
        result = #{self}.slice().sort(block);
      } else {
        result = #{self}.slice()['$sort']();
      }
      #{self}.length = 0;
      for(var i = 0; i < result.length; i++) {
        #{self}.push(result[i]);
      }
      return #{self};
    }
  end

  def take(count)
    `#{self}.slice(0, count)`
  end

  def take_while(&block)
    %x{
      var result = [];

      for (var i = 0, length = #{self}.length, item, value; i < length; i++) {
        item = #{self}[i];

        if ((value = block(item)) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === nil) {
          return result;
        }

        result.push(item);
      }

      return result;
    }
  end

  def to_a
    self
  end

  alias to_ary to_a

  def to_json
    %x{
      var result = [];

      for (var i = 0, length = #{self}.length; i < length; i++) {
        result.push(#{ `#{self}[i]`.to_json });
      }

      return '[' + result.join(', ') + ']';
    }
  end

  def to_native
    %x{
      var result = [], obj

      for (var i = 0, len = #{self}.length; i < len; i++) {
        obj = #{self}[i];

        if (obj.$to_native) {
          result.push(#{ `obj`.to_native });
        }
        else {
          result.push(obj);
        }
      }

      return result;
    }
  end


  alias to_s inspect

  def uniq
    %x{
      var result = [],
          seen   = {};

      for (var i = 0, length = #{self}.length, item, hash; i < length; i++) {
        item = #{self}[i];
        hash = item;

        if (!seen[hash]) {
          seen[hash] = true;

          result.push(item);
        }
      }

      return result;
    }
  end

  def uniq!
    %x{
      var original = #{self}.length,
          seen     = {};

      for (var i = 0, length = original, item, hash; i < length; i++) {
        item = #{self}[i];
        hash = item;

        if (!seen[hash]) {
          seen[hash] = true;
        }
        else {
          #{self}.splice(i, 1);

          length--;
          i--;
        }
      }

      return #{self}.length === original ? nil : #{self};
    }
  end

  def unshift(*objects)
    %x{
      for (var i = objects.length - 1; i >= 0; i--) {
        #{self}.unshift(objects[i]);
      }

      return #{self};
    }
  end

  def zip(*others, &block)
    %x{
      var result = [], size = #{self}.length, part, o;

      for (var i = 0; i < size; i++) {
        part = [#{self}[i]];

        for (var j = 0, jj = others.length; j < jj; j++) {
          o = others[j][i];

          if (o == null) {
            o = nil;
          }

          part[j + 1] = o;
        }

        result[i] = part;
      }

      if (block !== nil) {
        for (var i = 0; i < size; i++) {
          block(result[i]);
        }

        return nil;
      }

      return result;
    }
  end
end
