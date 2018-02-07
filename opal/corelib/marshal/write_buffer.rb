class NilClass
  def __marshal__(buffer)
    buffer.append('0')
  end
end

class Boolean
  def __marshal__(buffer)
    if `self`
      buffer.append('T')
    else
      buffer.append('F')
    end
  end
end

class Integer
  def __marshal__(buffer)
    if self >= -0x40000000 && self < 0x40000000
      buffer.append('i')
      buffer.write_fixnum(self)
    else
      buffer.append('l')
      buffer.write_bignum(self)
    end
  end
end

class Float
  def __marshal__(buffer)
    buffer.save_link(self)
    buffer.append('f')
    buffer.write_float(self)
  end
end

class String
  def __marshal__(buffer)
    buffer.save_link(self)
    buffer.write_ivars_prefix(self)
    buffer.write_extends(self)
    buffer.write_user_class(String, self)
    buffer.append('"')
    buffer.write_string(self)
  end
end

class Array
  def __marshal__(buffer)
    buffer.save_link(self)
    buffer.write_ivars_prefix(self)
    buffer.write_extends(self)
    buffer.write_user_class(Array, self)
    buffer.append('[')
    buffer.write_array(self)
    buffer.write_ivars_suffix(self)
  end
end

class Hash
  def __marshal__(buffer)
    if default_proc
      raise TypeError, "can't dump hash with default proc"
    end

    buffer.save_link(self)
    buffer.write_ivars_prefix(self)
    buffer.write_extends(self)
    buffer.write_user_class(Hash, self)
    if default
      buffer.append('}')
      buffer.write_hash(self)
      buffer.write(default)
    else
      buffer.append('{')
      buffer.write_hash(self)
    end
    buffer.write_ivars_suffix(self)
  end
end

class Regexp
  def __marshal__(buffer)
    buffer.save_link(self)
    buffer.write_ivars_prefix(self)
    buffer.write_extends(self)
    buffer.write_user_class(Regexp, self)
    buffer.append('/')
    buffer.write_regexp(self)
    buffer.write_ivars_suffix(self)
  end
end

class Proc
  def __marshal__(buffer)
    raise TypeError, "no _dump_data is defined for class #{self.class}"
  end
end

class Method
  def __marshal__(buffer)
    raise TypeError, "no _dump_data is defined for class #{self.class}"
  end
end

class MatchData
  def __marshal__(buffer)
    raise TypeError, "no _dump_data is defined for class #{self.class}"
  end
end

class Module
  def __marshal__(buffer)
    unless name
      raise TypeError, "can't dump anonymous module"
    end

    buffer.save_link(self)
    buffer.append('m')
    buffer.write_module(self)
  end
end

class Class
  def __marshal__(buffer)
    unless name
      raise TypeError, "can't dump anonymous class"
    end

    if singleton_class?
      raise TypeError, "singleton class can't be dumped"
    end

    buffer.save_link(self)
    buffer.append('c')
    buffer.write_class(self)
  end
end

class BasicObject
  def __marshal__(buffer)
    buffer.save_link(self)
    buffer.write_extends(self)
    buffer.append('o')
    buffer.write_object(self)
  end
end

class Range
  def __marshal__(buffer)
    buffer.save_link(self)
    buffer.write_extends(self)
    buffer.append('o')
    buffer.append_symbol(self.class.name)
    buffer.write_fixnum(3)
    buffer.append_symbol('excl')
    buffer.write(exclude_end?)
    buffer.append_symbol('begin')
    buffer.write(self.begin)
    buffer.append_symbol('end')
    buffer.write(self.end)
  end
end

class Struct
  def __marshal__(buffer)
    buffer.save_link(self)
    buffer.write_ivars_prefix(self)
    buffer.write_extends(self)
    buffer.append('S')
    buffer.append_symbol(self.class.name)
    buffer.write_fixnum(length)
    each_pair do |attr_name, value|
      buffer.append_symbol(attr_name)
      buffer.write(value)
    end
    buffer.write_ivars_suffix(self)
  end
end

module Marshal
  class WriteBuffer
    attr_reader :buffer

    def initialize(object)
      @object = object
      @buffer = BinaryString.new
      @cache = []
      @extends = Hash.new { |h, k| h[k] = [] }
      append(version)
    end

    def write(object = @object)
      if idx = @cache.index(object.object_id)
        write_object_link(idx)
      elsif object.respond_to?(:marshal_dump)
        write_usr_marshal(object)
      elsif object.respond_to?(:_dump)
        write_userdef(object)
      else
        case object
        when nil, true, false, Proc, Method, MatchData, Range, Struct, Array, Class, Module, Hash, Regexp
          object.__marshal__(self)
        when Integer
          Integer.instance_method(:__marshal__).bind(object).call(self)
        when Float
          Float.instance_method(:__marshal__).bind(object).call(self)
        when String
          String.instance_method(:__marshal__).bind(object).call(self)
        else
          BasicObject.instance_method(:__marshal__).bind(object).call(self)
        end
      end

      @buffer
    end

    def write_fixnum(n)
      %x{
        var s;

        if (n == 0) {
          s = String.fromCharCode(n);
        } else if (n > 0 && n < 123) {
          s = String.fromCharCode(n + 5);
        } else if (n < 0 && n > -124) {
          s = String.fromCharCode(256 + n - 5);
        } else {
          s = "";
          var cnt = 0;
          for (var i = 0; i < 4; i++) {
            var b = n & 255;
            s += String.fromCharCode(b);
            n >>= 8
            cnt += 1;
            if (n === 0 || n === -1) {
              break;
            }
          }
          var l_byte;
          if (n < 0) {
            l_byte = 256 - cnt;
          } else {
            l_byte = cnt;
          }
          s = String.fromCharCode(l_byte) + s;
        }
        #{append(`s`)}
      }
    end

    def write_bignum(n)
      sign = n > 0 ? '+' : '-'
      append(sign)

      num = n > 0 ? n : -n

      arr = []
      while num > 0
        arr << (num & 0xffff)
        num = (num / 0x10000).floor
      end

      write_fixnum(arr.size)

      arr.each do |x|
        append(`String.fromCharCode(x & 0xff)`)
        append(`String.fromCharCode(#{(x / 0x100).floor})`)
      end
    end

    def write_string(s)
      write_fixnum(s.length)
      append(s)
    end

    def append_symbol(sym)
      append(':')
      write_fixnum(sym.length)
      append(sym)
    end

    def write_array(a)
      write_fixnum(a.length)
      a.each do |item|
        write(item)
      end
    end

    def write_hash(h)
      write_fixnum(h.length)
      h.each do |key, value|
        write(key)
        write(value)
      end
    end

    def write_object(obj)
      append_symbol(obj.class.name)
      write_ivars_suffix(obj, true)
    end

    def write_class(klass)
      write_string(klass.name)
    end

    def write_module(mod)
      write_string(mod.name)
    end

    def write_regexp(regexp)
      write_string(regexp.to_s)
      append(`String.fromCharCode(#{regexp.options})`)
    end

    def write_float(f)
      if f.equal?(Float::INFINITY)
        write_string('inf')
      elsif f.equal?(-Float::INFINITY)
        write_string('-inf')
      elsif f.equal?(Float::NAN)
        write_string('nan')
      else
        write_string(f.to_s)
      end
    end

    def write_ivars_suffix(object, force = false)
      if object.instance_variables.empty? && !force
        return
      end

      write_fixnum(object.instance_variables.length)
      object.instance_variables.each do |ivar_name|
        append_symbol(ivar_name)
        write(object.instance_variable_get(ivar_name))
      end
    end

    def write_extends(object)
      singleton_mods = object.singleton_class.ancestors.reject { |mod| mod.is_a?(Class) }
      class_mods = object.class.ancestors.reject { |mod| mod.is_a?(Class) }
      own_mods = singleton_mods - class_mods
      if !own_mods.empty?
        own_mods.each do |mod|
          append('e')
          append_symbol(mod.name)
        end
      end
    end

    def write_user_class(klass, object)
      unless object.class.equal?(klass)
        append('C')
        append_symbol(object.class.name)
      end
    end

    def write_object_link(idx)
      append('@')
      write_fixnum(idx)
    end

    def save_link(object)
      @cache << object.object_id
    end

    def write_usr_marshal(object)
      value = object.marshal_dump
      klass = object.class
      append('U')
      namespace = `#{klass}.$$base_module`
      if namespace.equal?(Object)
        append_symbol(`#{klass}.$$name`)
      else
        append_symbol(namespace.name + '::' + `#{klass}.$$name`)
      end
      write(value)
    end

    def write_userdef(object)
      value = object._dump(0)

      unless value.is_a?(String)
        raise TypeError, '_dump() must return string'
      end

      write_ivars_prefix(value)
      append('u')
      append_symbol(object.class.name)
      write_string(value)
    end

    def write_ivars_prefix(object)
      if !object.instance_variables.empty?
        append('I')
      end
    end

    def append(s)
      @buffer += s
    end

    def version
      `String.fromCharCode(#{MAJOR_VERSION}, #{MINOR_VERSION})`
    end
  end
end
