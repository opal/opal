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
      @extended = []
      @ivars = []
    end

    def length
      @buffer.length
    end

    def read(cache: true, ivar_index: nil)
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
      when 'e'
        read_extended
        object = read
        apply_extends(object)
        object
      when 'C'
        read_user_class
        read
      when 'o'
        read_object
      when 'd'
        raise NotImplementedError, 'Data type cannot be demarshaled'
      when 'u'
        raise NotImplementedError, 'UserDef type cannot be demarshaled yet' # read_userdef
      when 'U'
        read_usrmarshal
      when 'f'
        read_float
      when 'l'
        read_bignum
      when '"'
        read_string(cache: cache)
      when '/'
        read_regexp
      when '['
        read_array
      when '{'
        read_hash
      when '}'
        raise NotImplementedError, 'Hashdef type cannot be demarshaled yet' # read_hashdef
      when 'S'
        read_struct
      when 'M'
        raise NotImplementedError, 'ModuleOld type cannot be demarshaled yet' # read_module_old
      when 'c'
        read_class
      when 'm'
        read_module
      when ':'
        read_symbol
      when ';'
        symbols_cache[read_fixnum]
      when 'I'
        ivar_index = @ivars.length
        @ivars << true
        object = read(cache: cache, ivar_index: ivar_index)
        set_ivars(object) if @ivars.pop
        object
      when '@'
        object_cache[read_fixnum]
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

    def set_ivars(obj)
      data = read_hash(cache: false)

      data.each do |ivar, value|
        case ivar
        when :E then # encodings are not supported
        when :encoding # encodings are not supported
        else
          if ivar.start_with?('@')
            obj.instance_variable_set(ivar, value)
          end
        end
      end

      if obj.respond_to?(:marshal_load)
        obj.marshal_load(data)
      end
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

    # Reads and returns a string from an input stream
    # Sometimes string shouldn't be cached using
    # an internal object cache, for a:
    #  + class/module name
    #  + float
    #  + regexp
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

    # Reads and saves a user class from an input stream
    #  Used for cases like String/Array subclasses
    #
    def read_user_class
      @user_class = read(cache: false)
    end

    # Constantizes and resets saved user class
    #
    def get_user_class
      klass = safe_const_get(@user_class)
      @user_class = nil
      klass
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
      result = if @ivars.last
        data = read_hash(cache: false)
        load_object(klass, data)
      else
        object = klass.allocate
        @object_cache << object
        set_ivars(object)
        object
      end
      result
    end

    # Loads an instance of passed klass using
    #  default marshal hooks
    #
    def load_object(klass, args)
      return klass._load(args) if klass.respond_to?(:_load)
      instance = klass.allocate
      instance.marshal_load(args) if instance.respond_to?(:marshal_load)
      instance
    end

    # Reads and returns a Struct from an input stream
    #
    def read_struct
      klass_name = read(cache: false)
      klass = safe_const_get(klass_name)
      args = read_hash(cache: false)
      result = load_object(klass, args)
      @object_cache << result
      result
    end

    # Reads and saves a Module from an input stream
    #  that was extending marshalled object
    #
    def read_extended
      @extended << read
    end

    # Applies all saved extending modules
    #  on the passed object
    #
    def apply_extends(object)
      @extended.reverse_each do |e|
        mod = safe_const_get(e)
        object.extend(mod)
      end
      @extended = []
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

    # Reads and returns Regexp from an input stream
    #
    def read_regexp
      args = [read_string(cache: false), read_byte]

      result = if @user_class
        load_object(get_user_class, args)
      else
        load_object(Regexp, args)
      end
      @object_cache << result
      result
    end

    # Reads and returns an abstract object from an input stream
    #  when the class of this object has custom marshalling rules
    #
    def read_usrmarshal
      klass_name = read
      klass = safe_const_get(klass_name)
      result = klass.allocate
      @object_cache << result
      data = read
      unless result.respond_to?(:marshal_load)
        raise TypeError, "instance of #{klass} needs to have method `marshal_load'"
      end
      result.marshal_load(data)
      result
    end
  end
end
