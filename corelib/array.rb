class Array
  include Enumerable

  def self.[](*objects)
    `
      var result = self.m$allocate();
      result.splice.apply(result, [0, 0].concat(objects));
      return result;
    `
  end

  def self.allocate
    `
      var array = [];
      array.$k = self;
      return array;
    `
  end

  def self.new(*a)
    `[]`
  end

  def &(other)
    `
      var result = [], seen = {};

      for (var i = 0, length = self.length; i < length; i++) {
        var item = self[i], hash = item;
        if (!seen[hash]) {
          for (var j = 0, length2 = other.length; j < length2; j++) {
            var item2 = other[j], hash2 = item2;

            if ((hash === hash2) && !seen[hash]) {
              seen[hash] = true;
              result.push(item);
            }
          }
        } 
      }
      return result;
    `
  end

  def *(other)
    `
      if (typeof other === 'string') return self.join(other);

      for (var i = 0, result = [], length = self.length; i < length; i++) {
        result = result.concat(self);
      }
      return result;
    `
  end

  def +(other)
    `self.slice(0).concat(other.slice(0))`
  end

  def <<(object)
    `
      self.push(object);
      return self;
    `
  end

  def <=>(other)
    `
      if (self.m$hash() === other.m$hash()) return 0;

      for (var i = 0, length = self.length, tmp; i < length; i++) {
        if (tmp = self[i].m$cmp$(null, other[i]) !== 0) return tmp;
      }

      return self.length === other.length ? 0 : (self.length > other.length ? 1 : -1);
    `
  end 

  def ==(other)
    `
      if (self.length !== other.length) return false;

      for (var i = 0, length = self.length; i < length; i++) {
        if (!self[i].m$eq$(null, other[i])) return false;
      }
      return true;
    `
  end

  # TODO: does not yet work with ranges
  def [](index, length = undefined)
    `
      var size = self.length;
      if (index < 0) index += size;

      if (length !== undefined) {
        if (length < 0 || index > size || index < 0) return nil;
        return self.slice(index, index + length);
      }
      else {
        if (index >= size || index < 0) return nil;
        return self[index];
      }
    `
  end

  # TODO: need to expand functionality
  def []=(index, value)
    `
      var size = self.length;
      if (index < 0) index += size;
      return self[index] = value;
    `
  end

  def assoc(object)
    `
      for (var i = 0, length = self.length, item; i < length; i++) {
        if (item = self[i], item.length && item[0].m$eq$(null, object))
          return item;
      }
      return nil;
    `
  end

  def at(index)
    `
      if (index < 0) index += self.length;
      if (index < 0 || index >= self.length) return nil;
      return self[index];
    `
  end

  def clear
    `
      self.splice(0);
      return self;
    `
  end

  def clone
    `self.slice(0)`
  end

  def collect(&block)
    `
      if (block === nil) return self.m$enum_for(null, "collect");
      var result = [], val;

      for (var i = 0, length = self.length; i < length; i++) {
        if ((val = $iterator.call($context, null, self[i])) === $breaker)
          return $breaker.$v;

        result[i] = val;
      }
      return result;
    `
  end

  def collect!(&block)
    `
      if (block === nil) return self.m$enum_for(null, "collect!");

      for (var i = 0, length = self.length, val; i < length; i++) {
        if ((val = $iterator.call($context, null, self[i])) === $breaker)
          return $breaker.$v;

        self[i] = val;
      }
      return self;
    `
  end

  def compact
    `
      var result = [], item;
      for (var i = 0, length = self.length; i < length; i++) {
        if ((item = self[i]) !== nil) result.push(item); 
      }
      return result;
    `
  end

  def compact!
    `
      var size = self.length;
      for (var i = 0, length = self.length; i < length; i++) {
        if (self[i] === nil) {
          self.splice(i, 1);
          length--;
          i--;
        }
      }
      return self.length === size ? nil : self;
    `
  end

  def concat(other)
    `
      for (var i = 0, length = other.length; i < length; i++) {
        self.push(other[i]);
      }
      return self;
    `
  end

  def count(object = undefined)
    `
      if (object === undefined) return self.length;
      for (var i = 0, length = self.length, result = 0; i < length; i++) {
        if (self[i].m$eq$(null, object)) result++;
      }
      return result;
    `
  end

  def delete(object)
    `
      var size = self.length;
      for (var i = 0, length = size; i < length; i++) {
        if (self[i].m$eq$(null, object)) {
          self.splice(i, 1);
          length--;
          i--;
        }
      }
      return self.length === size ? nil : object;
    `
  end

  def delete_at(index)
    `
      if (index < 0) index += self.length;
      if (index < 0 || index >= self.length) return nil;

      var result = self[index];
      self.splice(index, 1);
      return result;
    `
  end

  def delete_if(&block)
    `
      if (block === nil) return self.m$enum_for(null, "delete_if");

      for (var i = 0, length = self.length, val; i < length; i++) {
        if ((val = $iterator.call($context, null, self[i])) === $breaker)
          return $breaker.$v;

        if (val !== false && val !== nil) {
          self.splice(i, 1);
          length--;
          i--;
        }
      }
      return self;
    `
  end

  def drop(number)
    `number > self.length ? [] : self.slice(number)`
  end

  def drop_while(&block)
    `
      if (block === nil) return self.m$enum_for(null, "drop_while");

      for (var i = 0, length = self.length, val; i < length; i++) {
        if ((val = $iterator.call($context, null, self[i])) === $breaker)
          return $breaker.$v;

        if (val === false || val === nil) return self.slice(i);
      }
      return [];
    `
  end

  def each(&block)
    `
      if (block === nil) return self.m$enum_for(null, "each");

      for (var i = 0, length = self.length; i < length; i++) {
        if ($iterator.call($context, null, self[i]) === $breaker) 
          return $breaker.$v;
      }
      return self;
    `
  end

  def each_index(&block)
    `
      if (block === nil) return self.m$enum_for(null, "each_index");

      for (var i = 0, length = self.length; i < length; i++) {
        if ($iterator.call($context, null, i) === $breaker) 
          return $breaker.$v;
      }
      return self;
    `
  end

  def each_with_index(&block)
    `
      if (block === nil) return self.m$enum_for(null, "each_with_index");

      for (var i = 0, length = self.length; i < length; i++) {
        if ($iterator.call($context, null, self[i], i) === $breaker) 
          return $breaker.$v;
      }
      return self;
    `
  end

  def empty?
    `self.length === 0`
  end

  def fetch(index, defaults, &block)
    `
      var original = index;
      if (index < 0) index += self.length;
      if (index >= 0 && index < self.length) return self[index];
      if (defaults !==  undefined) return defaults;

      if (block !== nil) return $iterator.call($context, null, original);
      rb_raise(RubyIndexError, 'Array#fetch');
    `
  end

  def first(count = undefined)
    `
      if (count !== undefined) return self.slice(0, count);
      return self.length === 0 ? nil : self[0];
    `
  end

  def flatten(level = undefined)
    `
      var result = [], item;

      for (var i = 0, length = self.length; i < length; i++) {
        item = self[i];

        if (item.$f & T_ARRAY) {
          if (level === undefined)
            result = result.concat(item.m$flatten());
          else if (level === 0)
            result.push(item);
          else
            result = result.concat(item.m$flatten(null, level - 1));
        }
        else {
          result.push(item);
        }
      }
      return result;
    `
  end

  def flatten!(level = undefined)
    `
      var result = self.m$flatten(null, level);
      return self.length === result.length ? nil : self.m$clear().m$replace(null, result);
    `
  end

  def grep(pattern)
    `
      var result = [], item;
      for (var i = 0, length = self.length; i < length; i++) {
        item = self[i];
        if (pattern.m$eqq$(null, item)) result.push(item);
      }
      return result;
    `
  end

  def hash
    `self.$id || (self.$id = rb_hash_yield++)`
  end

  def include?(member)
    `
      for (var i = 0, length = self.length; i < length; i++) {
        if (self[i].m$eq$(null, member)) return true;
      }
      return false;
    `
  end

  def index(object = undefined, &block)
    `
      if (block === nil && object === undefined) return self.m$enum_for(null, "index");
      if (block !== nil) {
        for (var i = 0, length = self.length, val; i < length; i++) {
          if ((val = $iterator.call($context, null, self[i])) === $breaker)
            return $breaker.$v;

          if (val !== false && val !== nil) return i;
        }
      }
      else {
        for (var i = 0, length = self.length; i < length; i++) {
          if (self[i].m$eq$(null, object)) return i;
        }
      }
      return nil;
    `
  end

  def inject(initial = undefined, &block)
    `
      if (block === nil) return self.m$enum_for(null, "inject");
      var result, val, i;

      if (initial === undefined) {
        i = 1; result = self[0];
      }
      else {
        i = 0; result = initial;
      }

      for (var length = self.length; i < length; i++) {
        if ((val = $iterator.call($context, null, result, self[i])) === $breaker)
          return $breaker.$v;

        result = val;
      }
      return result;
    `
  end
end
