module JSON
  %x{
    var $parse  = JSON.parse,
        $hasOwn = Opal.hasOwnProperty;

    function to_opal(value, options) {
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
            var arr = #{`options.array_class`.new};

            for (var i = 0, ii = value.length; i < ii; i++) {
              #{`arr`.push(`to_opal(value[i], options)`)};
            }

            return arr;
          }
          else {
            var hash = #{`options.object_class`.new};

            for (var k in value) {
              if ($hasOwn.call(value, k)) {
                #{`hash`[`k`] = `to_opal(value[k], options)`};
              }
            }

            var klass;
            if ((klass = #{`hash`[JSON.create_id]}) != nil) {
              klass = Opal.cget(klass);
              return #{`klass`.json_create(`hash`)};
            }
            else {
              return hash;
            }
          }
      }
    };
  }

  class << self
    attr_accessor :create_id
  end

  self.create_id = :json_class

  def self.[](value, options = {})
    if String === value
      parse(value, options)
    else
      generate(value, options)
    end
  end

  def self.parse(source, options = {})
    from_object(`$parse(source)`, options)
  end

  def self.parse!(source, options = {})
    parse(source, options)
  end

  # Raw js object => opal object
  def self.from_object(js_object, options = {})
    options[:object_class] ||= Hash
    options[:array_class]  ||= Array

    `to_opal(js_object, #{options.to_n})`
  end

  def self.generate(obj, options = {})
    obj.to_json(options)
  end

  def self.dump(obj, io = nil, limit = nil)
    string = generate(obj)

    if io
      io = io.to_io if io.responds_to? :to_io
      io.write string

      io
    else
      string
    end
  end
end

class Object
  def to_json
    to_s.to_json
  end

  # FIXME: remove this
  def as_json
    nil
  end
end

class Array
  def to_json
    %x{
      var result = [];

      for (var i = 0, length = #{self}.length; i < length; i++) {
        result.push(#{`self[i]`.to_json});
      }

      return '[' + result.join(', ') + ']';
    }
  end

end

class Boolean
  # FIXME: remove this
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
      var inspect = [], keys = self.keys, map = self.map;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i];
        inspect.push(#{`key`.to_s.to_json} + ':' + #{`map[key]`.to_json});
      }

      return '{' + inspect.join(', ') + '}';
    }
  end
end

class NilClass
  # FIXME: remove this
  def as_json
    self
  end

  def to_json
    'null'
  end
end

class Numeric
  # FIXME: remove this
  def as_json
    self
  end

  def to_json
    `#{self}.toString()`
  end
end

class String
  # FIXME: remove this
  def as_json
    self
  end

  alias to_json inspect
end
