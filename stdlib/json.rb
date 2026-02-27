# backtick_javascript: true

module JSON
  class JSONError < StandardError
  end

  class ParserError < JSONError
  end

  %x{
    var $hasOwn = Opal.hasOwnProperty;

    function $parse(source) {
      try {
        return JSON.parse(source);
      } catch (e) {
        #{raise JSON::ParserError, `e.message`};
      }
    };

    function to_opal(value, options) {
      var klass, arr, hash, i, ii, k;

      switch (typeof value) {
        case 'string':
          return value;

        case 'number':
          return value;

        case 'boolean':
          return !!value;

        case 'undefined':
          return nil;

        case 'object':
          if (!value) return nil;

          if (value.$$is_array) {
            arr = #{`Opal.hash_get(options, 'array_class')`.new};

            for (i = 0, ii = value.length; i < ii; i++) {
              #{`arr`.push(`to_opal(value[i], options)`)};
            }

            return arr;
          }
          else {
            hash = #{`Opal.hash_get(options, 'object_class')`.new};

            for (k in value) {
              if ($hasOwn.call(value, k)) {
                #{`hash`[`k`] = `to_opal(value[k], options)`};
              }
            }

            if (!Opal.hash_get(options, 'parse') && (klass = #{`hash`[JSON.create_id]}) != nil) {
              return #{::Object.const_get(`klass`).json_create(`hash`)};
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
    from_object(`$parse(source)`, options.merge(parse: true))
  end

  def self.parse!(source, options = {})
    parse(source, options)
  end

  def self.load(source, options = {})
    from_object(`$parse(source)`, options)
  end

  # Raw js object => opal object
  def self.from_object(js_object, options = {})
    options[:object_class] ||= Hash
    options[:array_class]  ||= Array

    `to_opal(js_object, options)`
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
end

# BUG: Enumerable must come before Array, otherwise it overrides #to_json
#      this is due to how modules are implemented.
module Enumerable
  def to_json
    to_a.to_json
  end
end

class Array
  def to_json
    %x{
      var result = [];

      for (var i = 0, length = #{self}.length; i < length; i++) {
        result.push(#{`self[i]`.to_json});
      }

      return '[' + result.join(',') + ']';
    }
  end
end

class Boolean
  def to_json
    `(self == true) ? 'true' : 'false'`
  end
end

class Hash
  def to_json
    %x{
      var result = [];

      Opal.hash_each(self, false, function(key, value) {
        result.push(#{`key`.to_s.to_json} + ':' + #{`value`.to_json});
        return [false, false];
      });

      return '{' + result.join(',') + '}';
    }
  end
end

class NilClass
  def to_json
    'null'
  end
end

class Numeric
  def to_json
    `self.toString()`
  end
end

class String
  def to_json
    `JSON.stringify(self)`
  end
end

class Time
  def to_json
    strftime('%FT%T%z').to_json
  end
end

class Date
  def to_json
    to_s.to_json
  end

  def as_json
    to_s
  end
end

module ::Kernel
  def JSON(object, opts = nil)
    # If object is string-like, parse the string and return the parsed result as a Ruby data structure.
    # Otherwise, generate a JSON text from the Ruby data structure object and return it.
    if object.is_a?(::String)
      JSON.parse(object)
    else
      object.to_json(opts)
    end
  end

  def j(*objs)
    objs.each { |o| puts JSON.generate(o) }
  end

  # def jj(**objs)
  #   objs.each { |o| puts JSON.pretty_generate(o) }
  # end
end
