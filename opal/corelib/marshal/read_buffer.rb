# https://github.com/ruby/ruby/blob/trunk/doc/marshal.rdoc
# https://github.com/ruby/ruby/blob/trunk/marshal.c

module ::Marshal
  class self::ReadBuffer
    %x{
      function stringToBytes(string) {
        var i,
            singleByte,
            l = string.length,
            result = [];

        for (i = 0; i < l; i++) {
          singleByte = string.charCodeAt(i);
          result.push(singleByte);
        }
        return result;
      }
    }

    attr_reader :version, :buffer, :index, :object_cache, :symbols_cache

    def initialize(input)
      @buffer = `stringToBytes(#{input.to_s})`
      @index = 0
      major = read_byte
      minor = read_byte
      if major != MAJOR_VERSION || minor != MINOR_VERSION
        ::Kernel.raise ::TypeError, "incompatible marshal file format (can't be read)"
      end
      @version = "#{major}.#{minor}"
      @object_cache = []
      @symbols_cache = []
      @ivars = []
    end

    def length
      @buffer.length
    end

    def read(cache: true)
      code = read_char
      # The first character indicates the type of the object
      case code
      when '0'
        nil
      when 'T'
        true
      when 'F'
        false
      when 'i'
        read_fixnum
      when 'f'
        read_float
      when 'l'
        read_bignum
      when '"'
        read_string
      when ':'
        read_symbol
      when ';'
        read_cached_symbol
      when '['
        read_array
      when '{'
        read_hash
      when '}'
        read_hashdef
      when '/'
        read_regexp
      when 'S'
        read_struct
      when 'c'
        read_class
      when 'm'
        read_module
      when 'o'
        read_object
      when '@'
        read_cached_object
      when 'e'
        read_extended_object
      when 'I'
        read_primitive_with_ivars
      when 'C'
        read_user_class
      when 'u'
        read_user_defined
      when 'U'
        read_user_marshal
      when 'M'
        ::Kernel.raise ::NotImplementedError, 'ModuleOld type cannot be demarshaled yet' # read_module_old
      when 'd'
        ::Kernel.raise ::NotImplementedError, 'Data type cannot be demarshaled'
      else
        ::Kernel.raise ::ArgumentError, 'dump format error'
      end
    end

    def read_byte
      if @index >= length
        ::Kernel.raise ::ArgumentError, 'marshal data too short'
      end
      result = @buffer[@index]
      @index += 1
      result
    end

    def read_char
      `String.fromCharCode(#{read_byte})`
    end

    # Reads and returns a fixnum from an input stream
    #
    def read_fixnum
      %x{
        var x, i, c = (#{read_byte} ^ 128) - 128;
        if (c === 0) {
          return 0;
        }

        if (c > 0) {
          if (4 < c && c < 128) {
            return c - 5;
          }
          x = 0;
          for (i = 0; i < c; i++) {
            x |= (#{read_byte} << (8*i));
          }
        } else {
          if (-129 < c && c < -4) {
            return c + 5;
          }

          c = -c;
          x = -1;

          for (i = 0; i < c; i++) {
            x &= ~(0xff << (8*i));
            x |= (#{read_byte} << (8*i));
          }
        }

        return x;
      }
    end

    # Reads and returns Float from an input stream
    #
    # @example
    #   123.456
    # Is encoded as
    #   'f', '123.456'
    #
    def read_float
      s = read_string(cache: false)
      result = if s == 'nan'
                 0.0 / 0
               elsif s == 'inf'
                 1.0 / 0
               elsif s == '-inf'
                 -1.0 / 0
               else
                 s.to_f
               end
      @object_cache << result
      result
    end

    # Reads and returns Bignum from an input stream
    #
    def read_bignum
      sign = read_char == '-' ? -1 : 1
      size = read_fixnum * 2
      result = 0
      (0...size).each do |exp|
        result += read_char.ord * 2**(exp * 8)
      end
      result = result.to_i * sign
      @object_cache << result
      result
    end

    # Reads and returns a string from an input stream
    # Sometimes string shouldn't be cached using
    # an internal object cache, for a:
    #  + class/module name
    #  + string representation of float
    #  + string representation of regexp
    #
    def read_string(cache: true)
      length = read_fixnum
      %x{
        var i, result = '';

        for (i = 0; i < length; i++) {
          result += #{read_char};
        }

        if (cache) {
          self.object_cache.push(result);
        }

        return result;
      }
    end

    # Reads and returns a symbol from an input stream
    #
    def read_symbol
      length = read_fixnum
      %x{
        var i, result = '';

        for (i = 0; i < length; i++) {
          result += #{read_char};
        }

        self.symbols_cache.push(result);

        return result;
      }
    end

    # Reads a symbol that was previously cache by its link
    #
    # @example
    #   [:a, :a, :b, :b, :c, :c]
    # Is encoded as
    #   '[', 6, :a, @0, :b, @1, :c, @2
    #
    def read_cached_symbol
      symbols_cache[read_fixnum]
    end

    # Reads and returns an array from an input stream
    #
    # @example
    #   [100, 200, 300]
    # is encoded as
    #   '[', 3, 100, 200, 300
    #
    def read_array
      result = []
      @object_cache << result
      length = read_fixnum
      %x{
        if (length > 0) {
          while (result.length < length) {
            result.push(#{read});
          }
        }

        return result;
      }
    end

    # Reads and returns a hash from an input stream
    # Sometimes hash shouldn't  be cached using
    # an internal object cache, for a:
    #  + hash of instance variables
    #  + hash of struct attributes
    #
    # @example
    #   {100 => 200, 300 => 400}
    # is encoded as
    #   '{', 2, 100, 200, 300, 400
    #
    def read_hash(cache: true)
      result = {}

      if cache
        @object_cache << result
      end

      length = read_fixnum
      %x{
        if (length > 0) {
          var key, value, i;
          for (i = 0; i < #{length}; i++) {
            key = #{read};
            value = #{read};
            #{result[`key`] = `value`};
          }
        }
        return result;
      }
    end

    # Reads and returns a hash with default value
    #
    # @example
    #   Hash.new(:default).merge(100 => 200)
    # is encoded as
    #   '}', 1, 100, 200, :default
    #
    def read_hashdef
      hash = read_hash
      default_value = read
      hash.default = default_value
      hash
    end

    # Reads and returns Regexp from an input stream
    #
    # @example
    #   r = /regexp/mix
    # is encoded as
    #   '/', 'regexp', r.options.chr
    #
    def read_regexp
      string = read_string(cache: false)
      options = read_byte

      result = ::Regexp.new(string, options)
      @object_cache << result
      result
    end

    # Reads and returns a Struct from an input stream
    #
    # @example
    #   Point = Struct.new(:x, :y)
    #   Point.new(100, 200)
    # is encoded as
    #   'S', :Point, {:x => 100, :y => 200}
    #
    def read_struct
      klass_name = read(cache: false)
      klass = safe_const_get(klass_name)
      attributes = read_hash(cache: false)
      args = attributes.values_at(*klass.members)
      result = klass.new(*args)
      @object_cache << result
      result
    end

    # Reads and returns a Class from an input stream
    #
    # @example
    #   String
    # is encoded as
    #   'c', 'String'
    #
    def read_class
      klass_name = read_string(cache: false)
      result = safe_const_get(klass_name)
      unless result.class == ::Class
        ::Kernel.raise ::ArgumentError, "#{klass_name} does not refer to a Class"
      end
      @object_cache << result
      result
    end

    # Reads and returns a Module from an input stream
    #
    # @example
    #   Kernel
    # is encoded as
    #   'm', 'Kernel'
    #
    def read_module
      mod_name = read_string(cache: false)
      result = safe_const_get(mod_name)
      unless result.class == ::Module
        ::Kernel.raise ::ArgumentError, "#{mod_name} does not refer to a Module"
      end
      @object_cache << result
      result
    end

    # Reads and returns an abstract object from an input stream
    #
    # @example
    #   obj = Object.new
    #   obj.instance_variable_set(:@ivar, 100)
    #   obj
    # is encoded as
    #   'o', :Object, {:@ivar => 100}
    #
    # The only exception is a Range class (and its subclasses)
    # For some reason in MRI isntances of this class have instance variables
    # - begin
    # - end
    # - excl
    # without '@' perfix.
    #
    def read_object
      klass_name = read(cache: false)
      klass = safe_const_get(klass_name)

      object = klass.allocate
      @object_cache << object

      ivars = read_hash(cache: false)
      ivars.each do |name, value|
        if name[0] == '@'
          object.instance_variable_set(name, value)
        else
          # MRI allows an object to have ivars that do not start from '@'
          # https://github.com/ruby/ruby/blob/ab3a40c1031ff3a0535f6bcf26de40de37dbb1db/range.c#L1225
          `object[name] = value`
        end
      end

      object
    end

    # Reads an object that was cached previously by its link
    #
    # @example
    #   obj1 = Object.new
    #   obj2 = Object.new
    #   obj3 = Object.new
    #   [obj1, obj1, obj2, obj2, obj3, obj3]
    # is encoded as
    #   [obj1, @1, obj2, @2, obj3, @3]
    #
    # NOTE: array itself is cached as @0, that's why obj1 is cached a @1, obj2 is @2, etc.
    #
    def read_cached_object
      object_cache[read_fixnum]
    end

    # Reads an object that was dynamically extended before marshaling like
    #
    # @example
    #   M1 = Module.new
    #   M2 = Module.new
    #   obj = Object.new
    #   obj.extend(M1)
    #   obj.extend(M2)
    #   obj
    # is encoded as
    #   'e', :M2, :M1, obj
    #
    def read_extended_object
      mod = safe_const_get(read)
      object = read
      object.extend(mod)
      object
    end

    # Reads a primitive object with instance variables
    # (classes that have their own marshalling rules, like Array/Hash/Regexp/etc)
    #
    # @example
    #   arr = [100, 200, 300]
    #   arr.instance_variable_set(:@ivar, :value)
    #   arr
    # is encoded as
    #   'I', [100, 200, 300], {:@ivar => value}
    #
    def read_primitive_with_ivars
      object = read

      primitive_ivars = read_hash(cache: false)

      if primitive_ivars.any? && object.is_a?(String)
        object = `new String(object)`
      end

      primitive_ivars.each do |name, value|
        if name != 'E'
          object.instance_variable_set(name, value)
        end
      end

      object
    end

    # Reads and User Class (instance of String/Regexp/Array/Hash subclass)
    #
    # @example
    #   UserArray = Class.new(Array)
    #   UserArray[100, 200, 300]
    # is encoded as
    #   'C', :UserArray, [100, 200, 300]
    #
    def read_user_class
      klass_name = read(cache: false)
      klass = safe_const_get(klass_name)
      value = read(cache: false)

      result = if klass < Hash
                 klass[value]
               else
                 klass.new(value)
               end

      @object_cache << result

      result
    end

    # Reads a 'User Defined' object that has '_dump/self._load' methods
    #
    # @example
    #   class UserDefined
    #     def _dump(level)
    #       '_dumped'
    #     end
    #   end
    #
    #   UserDefined.new
    # is encoded as
    #   'u', :UserDefined, '_dumped'
    #
    # To load it back UserDefined._load' must be used.
    #
    def read_user_defined
      klass_name = read(cache: false)
      klass = safe_const_get(klass_name)
      data = read_string(cache: false)
      result = klass._load(data)

      @object_cache << result

      result
    end

    # Reads a 'User Marshal' object that has 'marshal_dump/marshal_load' methods
    #
    # @example
    #   class UserMarshal < Struct.new(:a, :b)
    #     def marshal_dump
    #       [a, b]
    #     end
    #
    #     def marshal_load(data)
    #       self.a, self.b = data
    #     end
    #   end
    #
    #   UserMarshal.new(100, 200)
    # is encoded as
    #   'U', :UserMarshal, [100, 200]
    #
    # To load it back `UserMarshal.allocate` and `UserMarshal#marshal_load` must be called
    #
    def read_user_marshal
      klass_name = read(cache: false)
      klass = safe_const_get(klass_name)

      result = klass.allocate
      @object_cache << result

      data = read(cache: false)
      result.marshal_load(data)
      result
    end

    # Returns a constant by passed const_name,
    #  re-raises Marshal-specific error when it's missing
    #
    def safe_const_get(const_name)
      ::Object.const_get(const_name)
    rescue ::NameError
      ::Kernel.raise ::ArgumentError, "undefined class/module #{const_name}"
    end
  end
end
