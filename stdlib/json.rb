`var json_parse = JSON.parse, __hasOwn = Object.prototype.hasOwnProperty`

module JSON
  def self.parse(source)
    `return to_opal(json_parse(source));`
  end

  # Raw js object => opal object
  def self.from_object(js_object)
    `return to_opal(js_object)`
  end

  %x{
    function to_opal(value) {
      switch (typeof value) {
        case 'string':
          return value;

        case 'number':
          return value;

        case 'boolean':
          return !!value;

        case 'null':
          return nil;

        case 'object':
          if (!value) return nil;

          if (value._isArray) {
            var arr = [];

            for (var i = 0, ii = value.length; i < ii; i++) {
              arr.push(to_opal(value[i]));
            }

            return arr;
          }
          else {
            var hash = #{ {} }, v, map = hash.map, keys = hash.keys;

            for (var k in value) {
              if (__hasOwn.call(value, k)) {
                v = to_opal(value[k]);
                keys.push(k);
                map[k] = v;
              }
            }
          }

          return hash;
      }
    };
  }
end

module Kernel
  def to_json
    to_s.to_json
  end

  def as_json
    nil
  end
end

class Array
  def to_json
    %x{
      var result = [];

      for (var i = 0, length = #{self}.length; i < length; i++) {
        result.push(#{ `#{self}[i]`.to_json });
      }

      return '[' + result.join(', ') + ']';
    }
  end

end

class Boolean
  def as_json
    self
  end

  def to_json
    `(#{self} == true) ? 'true' : 'false'`
  end
end

class Hash
  def to_json
    %x{
      var inspect = [], keys = #{self}.keys, map = #{self}.map;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i];
        inspect.push(#{`key`.to_json} + ': ' + #{`map[key]`.to_json});
      }

      return '{' + inspect.join(', ') + '}';
    }
  end
end

class NilClass
  def as_json
    self
  end

  def to_json
    'null'
  end
end

class Numeric
  def as_json
    self
  end

  def to_json
    `#{self}.toString()`
  end
end

class String
  def as_json
    self
  end

  alias to_json inspect
end
