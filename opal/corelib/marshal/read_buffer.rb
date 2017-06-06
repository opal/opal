module Marshal
  class ReadBuffer
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

    attr_reader :version, :buffer, :index, :user_class, :extended, :object_cache, :symbols_cache

    def initialize(input)
      @buffer = `stringToBytes(#{input.to_s})`
      @index = 0
      major = read_byte
      minor = read_byte
      if major != MAJOR_VERSION || minor != MINOR_VERSION
        raise TypeError, "incompatible marshal file format (can't be read)"
      end
      @version = "#{major}.#{minor}"
      @object_cache = []
      @symbols_cache = []
      # @extended = []
      @ivars = []
    end

    def length
      @buffer.length
    end

    def read(cache: true)
      code = read_char
      # The first character indicates the type of the object
      result = case code
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
        raise NotImplementedError, 'ModuleOld type cannot be demarshaled yet' # read_module_old
      when 'd'
        raise NotImplementedError, 'Data type cannot be demarshaled'
      else
        raise ArgumentError, "dump format error"
      end
      result
    end

    def read_byte
      if @index >= length
        raise ArgumentError, "marshal data too short"
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
    def read_float
      s = read_string(cache: false)
      result = if s == "nan"
        0.0 / 0
      elsif s == "inf"
        1.0 / 0
      elsif s == "-inf"
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
        result += (read_char.ord) * 2 ** (exp * 8)
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

    def read_cached_symbol
      symbols_cache[read_fixnum]
    end

    # Reads and returns an array from an input stream
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

    def read_hashdef
      hash = read_hash
      default_value = read
      hash.default = default_value
      hash
    end

    # Reads and returns Regexp from an input stream
    #
    def read_regexp
      string = read_string(cache: false)
      options = read_byte

      result = Regexp.new(string, options)
      @object_cache << result
      result
    end

    # Reads and returns a Struct from an input stream
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
    def read_class
      klass_name = read_string(cache: false)
      result = safe_const_get(klass_name)
      unless result.class == Class
        raise ArgumentError, "#{klass_name} does not refer to a Class"
      end
      @object_cache << result
      result
    end

    # Reads and returns a Module from an input stream
    #
    def read_module
      mod_name = read_string(cache: false)
      result = safe_const_get(mod_name)
      unless result.class == Module
        raise ArgumentError, "#{mod_name} does not refer to a Module"
      end
      @object_cache << result
      result
    end

    # Reads and returns an abstract object from an input stream
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

    def read_cached_object
      object_cache[read_fixnum]
    end

    def read_extended_object
      mod = safe_const_get(read)
      object = read
      object.extend(mod)
      object
    end

    def read_primitive_with_ivars
      object = read

      primitive_ivars = read_hash(cache: false)
      primitive_ivars.each do |name, value|
        if name != 'E'
          object.instance_variable_set(name, value)
        end
      end

      object
    end

    # Reads and User Class (instance of String/Regexp/Array/Hash subclass)
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

    def read_user_defined
      klass_name = read(cache: false)
      klass = safe_const_get(klass_name)
      data = read_string(cache: false)
      result = klass._load(data)

      @object_cache << result

      result
    end

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
      begin
        Object.const_get(const_name)
      rescue NameError
        raise ArgumentError, "undefined class/module #{const_name}"
      end
    end
  end
end
