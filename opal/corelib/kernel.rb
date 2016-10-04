module Kernel
  def method_missing(symbol, *args, &block)
    raise NoMethodError.new("undefined method `#{symbol}' for #{inspect}", symbol, args)
  end

  def =~(obj)
    false
  end

  def !~(obj)
    not(self =~ obj)
  end

  def ===(other)
    self.object_id == other.object_id || self == other
  end

  def <=>(other)
    %x{
      // set guard for infinite recursion
      self.$$comparable = true;

      var x = #{self == other};

      if (x && x !== nil) {
        return 0;
      }

      return nil;
    }
  end

  def method(name)
    %x{
      var meth = self['$' + name];

      if (!meth || meth.$$stub) {
        #{raise NameError.new("undefined method `#{name}' for class `#{self.class}'", name)};
      }

      return #{Method.new(self, `meth`, name)};
    }
  end

  def methods(all = true)
    %x{
      var methods = [];

      for (var key in self) {
        if (key[0] == "$" && typeof(self[key]) === "function") {
          if (all == false || all === nil) {
            if (!Opal.hasOwnProperty.call(self, key)) {
              continue;
            }
          }
          if (self[key].$$stub === undefined) {
            methods.push(key.substr(1));
          }
        }
      }

      return methods;
    }
  end

  alias public_methods methods

  def Array(object)
    %x{
      var coerced;

      if (object === nil) {
        return [];
      }

      if (object.$$is_array) {
        return object;
      }

      coerced = #{Opal.coerce_to?(object, Array, :to_ary)};
      if (coerced !== nil) { return coerced; }

      coerced = #{Opal.coerce_to?(object, Array, :to_a)};
      if (coerced !== nil) { return coerced; }

      return [object];
    }
  end

  def at_exit(&block)
    $__at_exit__ ||= []
    $__at_exit__ << block
  end

  # Opal does not support #caller, but we stub it as an empty array to not
  # break dependant libs
  def caller
    []
  end

  def class
    `self.$$class`
  end

  def copy_instance_variables(other)
    %x{
      for (var name in other) {
        if (other.hasOwnProperty(name) && name.charAt(0) !== '$') {
          self[name] = other[name];
        }
      }
    }
  end

  def copy_singleton_methods(other)
    %x{
      var name;

      if (other.hasOwnProperty('$$meta')) {
        var other_singleton_class_proto = Opal.get_singleton_class(other).$$proto;
        var self_singleton_class_proto = Opal.get_singleton_class(self).$$proto;

        for (name in other_singleton_class_proto) {
          if (name.charAt(0) === '$' && other_singleton_class_proto.hasOwnProperty(name)) {
            self_singleton_class_proto[name] = other_singleton_class_proto[name];
          }
        }
      }

      for (name in other) {
        if (name.charAt(0) === '$' && name.charAt(1) !== '$' && other.hasOwnProperty(name)) {
          self[name] = other[name];
        }
      }
    }
  end

  def clone
    copy = self.class.allocate

    copy.copy_instance_variables(self)
    copy.copy_singleton_methods(self)
    copy.initialize_clone(self)

    copy
  end

  def initialize_clone(other)
    initialize_copy(other)
  end

  def define_singleton_method(name, method = undefined, &block)
    singleton_class.define_method(name, method, &block)
  end

  def dup
    copy = self.class.allocate

    copy.copy_instance_variables(self)
    copy.initialize_dup(self)

    copy
  end

  def initialize_dup(other)
    initialize_copy(other)
  end

  def enum_for(method = :each, *args, &block)
    Enumerator.for(self, method, *args, &block)
  end

  alias to_enum enum_for

  def equal?(other)
    `self === other`
  end

  def exit(status = true)
    $__at_exit__ ||= []

    while $__at_exit__.size > 0
      block = $__at_exit__.pop
      block.call
    end

    status = 0 if `status === true` # it's in JS because it can be null/undef
    `Opal.exit(status);`
    nil
  end

  def extend(*mods)
    %x{
      var singleton = #{singleton_class};

      for (var i = mods.length - 1; i >= 0; i--) {
        var mod = mods[i];

        if (!mod.$$is_module) {
          #{raise TypeError, "wrong argument type #{`mod`.class} (expected Module)"};
        }

        #{`mod`.append_features `singleton`};
        #{`mod`.extended self};
      }
    }

    self
  end

  def format(format_string, *args)
    if args.length == 1 && args[0].respond_to?(:to_ary)
      ary = Opal.coerce_to?(args[0], Array, :to_ary)
      args = ary.to_a unless ary.nil?
    end

    %x{
      var result = '',
          //used for slicing:
          begin_slice = 0,
          end_slice,
          //used for iterating over the format string:
          i,
          len = format_string.length,
          //used for processing field values:
          arg,
          str,
          //used for processing %g and %G fields:
          exponent,
          //used for keeping track of width and precision:
          width,
          precision,
          //used for holding temporary values:
          tmp_num,
          //used for processing %{} and %<> fileds:
          hash_parameter_key,
          closing_brace_char,
          //used for processing %b, %B, %o, %x, and %X fields:
          base_number,
          base_prefix,
          base_neg_zero_regex,
          base_neg_zero_digit,
          //used for processing arguments:
          next_arg,
          seq_arg_num = 1,
          pos_arg_num = 0,
          //used for keeping track of flags:
          flags,
          FNONE  = 0,
          FSHARP = 1,
          FMINUS = 2,
          FPLUS  = 4,
          FZERO  = 8,
          FSPACE = 16,
          FWIDTH = 32,
          FPREC  = 64,
          FPREC0 = 128;

      function CHECK_FOR_FLAGS() {
        if (flags&FWIDTH) { #{raise ArgumentError, 'flag after width'} }
        if (flags&FPREC0) { #{raise ArgumentError, 'flag after precision'} }
      }

      function CHECK_FOR_WIDTH() {
        if (flags&FWIDTH) { #{raise ArgumentError, 'width given twice'} }
        if (flags&FPREC0) { #{raise ArgumentError, 'width after precision'} }
      }

      function GET_NTH_ARG(num) {
        if (num >= args.length) { #{raise ArgumentError, 'too few arguments'} }
        return args[num];
      }

      function GET_NEXT_ARG() {
        switch (pos_arg_num) {
        case -1: #{raise ArgumentError, "unnumbered(#{`seq_arg_num`}) mixed with numbered"}
        case -2: #{raise ArgumentError, "unnumbered(#{`seq_arg_num`}) mixed with named"}
        }
        pos_arg_num = seq_arg_num++;
        return GET_NTH_ARG(pos_arg_num - 1);
      }

      function GET_POS_ARG(num) {
        if (pos_arg_num > 0) {
          #{raise ArgumentError, "numbered(#{`num`}) after unnumbered(#{`pos_arg_num`})"}
        }
        if (pos_arg_num === -2) {
          #{raise ArgumentError, "numbered(#{`num`}) after named"}
        }
        if (num < 1) {
          #{raise ArgumentError, "invalid index - #{`num`}$"}
        }
        pos_arg_num = -1;
        return GET_NTH_ARG(num - 1);
      }

      function GET_ARG() {
        return (next_arg === undefined ? GET_NEXT_ARG() : next_arg);
      }

      function READ_NUM(label) {
        var num, str = '';
        for (;; i++) {
          if (i === len) {
            #{raise ArgumentError, 'malformed format string - %*[0-9]'}
          }
          if (format_string.charCodeAt(i) < 48 || format_string.charCodeAt(i) > 57) {
            i--;
            num = parseInt(str, 10) || 0;
            if (num > 2147483647) {
              #{raise ArgumentError, "#{`label`} too big"}
            }
            return num;
          }
          str += format_string.charAt(i);
        }
      }

      function READ_NUM_AFTER_ASTER(label) {
        var arg, num = READ_NUM(label);
        if (format_string.charAt(i + 1) === '$') {
          i++;
          arg = GET_POS_ARG(num);
        } else {
          arg = GET_NEXT_ARG();
        }
        return #{`arg`.to_int};
      }

      for (i = format_string.indexOf('%'); i !== -1; i = format_string.indexOf('%', i)) {
        str = undefined;

        flags = FNONE;
        width = -1;
        precision = -1;
        next_arg = undefined;

        end_slice = i;

        i++;

        switch (format_string.charAt(i)) {
        case '%':
          begin_slice = i;
        case '':
        case '\n':
        case '\0':
          i++;
          continue;
        }

        format_sequence: for (; i < len; i++) {
          switch (format_string.charAt(i)) {

          case ' ':
            CHECK_FOR_FLAGS();
            flags |= FSPACE;
            continue format_sequence;

          case '#':
            CHECK_FOR_FLAGS();
            flags |= FSHARP;
            continue format_sequence;

          case '+':
            CHECK_FOR_FLAGS();
            flags |= FPLUS;
            continue format_sequence;

          case '-':
            CHECK_FOR_FLAGS();
            flags |= FMINUS;
            continue format_sequence;

          case '0':
            CHECK_FOR_FLAGS();
            flags |= FZERO;
            continue format_sequence;

          case '1':
          case '2':
          case '3':
          case '4':
          case '5':
          case '6':
          case '7':
          case '8':
          case '9':
            tmp_num = READ_NUM('width');
            if (format_string.charAt(i + 1) === '$') {
              if (i + 2 === len) {
                str = '%';
                i++;
                break format_sequence;
              }
              if (next_arg !== undefined) {
                #{raise ArgumentError, "value given twice - %#{`tmp_num`}$"}
              }
              next_arg = GET_POS_ARG(tmp_num);
              i++;
            } else {
              CHECK_FOR_WIDTH();
              flags |= FWIDTH;
              width = tmp_num;
            }
            continue format_sequence;

          case '<':
          case '\{':
            closing_brace_char = (format_string.charAt(i) === '<' ? '>' : '\}');
            hash_parameter_key = '';

            i++;

            for (;; i++) {
              if (i === len) {
                #{raise ArgumentError, 'malformed name - unmatched parenthesis'}
              }
              if (format_string.charAt(i) === closing_brace_char) {

                if (pos_arg_num > 0) {
                  #{raise ArgumentError, "named #{`hash_parameter_key`} after unnumbered(#{`pos_arg_num`})"}
                }
                if (pos_arg_num === -1) {
                  #{raise ArgumentError, "named #{`hash_parameter_key`} after numbered"}
                }
                pos_arg_num = -2;

                if (args[0] === undefined || !args[0].$$is_hash) {
                  #{raise ArgumentError, 'one hash required'}
                }

                next_arg = #{`args[0]`.fetch(`hash_parameter_key`)};

                if (closing_brace_char === '>') {
                  continue format_sequence;
                } else {
                  str = next_arg.toString();
                  if (precision !== -1) { str = str.slice(0, precision); }
                  if (flags&FMINUS) {
                    while (str.length < width) { str = str + ' '; }
                  } else {
                    while (str.length < width) { str = ' ' + str; }
                  }
                  break format_sequence;
                }
              }
              hash_parameter_key += format_string.charAt(i);
            }

          case '*':
            i++;
            CHECK_FOR_WIDTH();
            flags |= FWIDTH;
            width = READ_NUM_AFTER_ASTER('width');
            if (width < 0) {
              flags |= FMINUS;
              width = -width;
            }
            continue format_sequence;

          case '.':
            if (flags&FPREC0) {
              #{raise ArgumentError, 'precision given twice'}
            }
            flags |= FPREC|FPREC0;
            precision = 0;
            i++;
            if (format_string.charAt(i) === '*') {
              i++;
              precision = READ_NUM_AFTER_ASTER('precision');
              if (precision < 0) {
                flags &= ~FPREC;
              }
              continue format_sequence;
            }
            precision = READ_NUM('precision');
            continue format_sequence;

          case 'd':
          case 'i':
          case 'u':
            arg = #{Integer(`GET_ARG()`)};
            if (arg >= 0) {
              str = arg.toString();
              while (str.length < precision) { str = '0' + str; }
              if (flags&FMINUS) {
                if (flags&FPLUS || flags&FSPACE) { str = (flags&FPLUS ? '+' : ' ') + str; }
                while (str.length < width) { str = str + ' '; }
              } else {
                if (flags&FZERO && precision === -1) {
                  while (str.length < width - ((flags&FPLUS || flags&FSPACE) ? 1 : 0)) { str = '0' + str; }
                  if (flags&FPLUS || flags&FSPACE) { str = (flags&FPLUS ? '+' : ' ') + str; }
                } else {
                  if (flags&FPLUS || flags&FSPACE) { str = (flags&FPLUS ? '+' : ' ') + str; }
                  while (str.length < width) { str = ' ' + str; }
                }
              }
            } else {
              str = (-arg).toString();
              while (str.length < precision) { str = '0' + str; }
              if (flags&FMINUS) {
                str = '-' + str;
                while (str.length < width) { str = str + ' '; }
              } else {
                if (flags&FZERO && precision === -1) {
                  while (str.length < width - 1) { str = '0' + str; }
                  str = '-' + str;
                } else {
                  str = '-' + str;
                  while (str.length < width) { str = ' ' + str; }
                }
              }
            }
            break format_sequence;

          case 'b':
          case 'B':
          case 'o':
          case 'x':
          case 'X':
            switch (format_string.charAt(i)) {
            case 'b':
            case 'B':
              base_number = 2;
              base_prefix = '0b';
              base_neg_zero_regex = /^1+/;
              base_neg_zero_digit = '1';
              break;
            case 'o':
              base_number = 8;
              base_prefix = '0';
              base_neg_zero_regex = /^3?7+/;
              base_neg_zero_digit = '7';
              break;
            case 'x':
            case 'X':
              base_number = 16;
              base_prefix = '0x';
              base_neg_zero_regex = /^f+/;
              base_neg_zero_digit = 'f';
              break;
            }
            arg = #{Integer(`GET_ARG()`)};
            if (arg >= 0) {
              str = arg.toString(base_number);
              while (str.length < precision) { str = '0' + str; }
              if (flags&FMINUS) {
                if (flags&FPLUS || flags&FSPACE) { str = (flags&FPLUS ? '+' : ' ') + str; }
                if (flags&FSHARP && arg !== 0) { str = base_prefix + str; }
                while (str.length < width) { str = str + ' '; }
              } else {
                if (flags&FZERO && precision === -1) {
                  while (str.length < width - ((flags&FPLUS || flags&FSPACE) ? 1 : 0) - ((flags&FSHARP && arg !== 0) ? base_prefix.length : 0)) { str = '0' + str; }
                  if (flags&FSHARP && arg !== 0) { str = base_prefix + str; }
                  if (flags&FPLUS || flags&FSPACE) { str = (flags&FPLUS ? '+' : ' ') + str; }
                } else {
                  if (flags&FSHARP && arg !== 0) { str = base_prefix + str; }
                  if (flags&FPLUS || flags&FSPACE) { str = (flags&FPLUS ? '+' : ' ') + str; }
                  while (str.length < width) { str = ' ' + str; }
                }
              }
            } else {
              if (flags&FPLUS || flags&FSPACE) {
                str = (-arg).toString(base_number);
                while (str.length < precision) { str = '0' + str; }
                if (flags&FMINUS) {
                  if (flags&FSHARP) { str = base_prefix + str; }
                  str = '-' + str;
                  while (str.length < width) { str = str + ' '; }
                } else {
                  if (flags&FZERO && precision === -1) {
                    while (str.length < width - 1 - (flags&FSHARP ? 2 : 0)) { str = '0' + str; }
                    if (flags&FSHARP) { str = base_prefix + str; }
                    str = '-' + str;
                  } else {
                    if (flags&FSHARP) { str = base_prefix + str; }
                    str = '-' + str;
                    while (str.length < width) { str = ' ' + str; }
                  }
                }
              } else {
                str = (arg >>> 0).toString(base_number).replace(base_neg_zero_regex, base_neg_zero_digit);
                while (str.length < precision - 2) { str = base_neg_zero_digit + str; }
                if (flags&FMINUS) {
                  str = '..' + str;
                  if (flags&FSHARP) { str = base_prefix + str; }
                  while (str.length < width) { str = str + ' '; }
                } else {
                  if (flags&FZERO && precision === -1) {
                    while (str.length < width - 2 - (flags&FSHARP ? base_prefix.length : 0)) { str = base_neg_zero_digit + str; }
                    str = '..' + str;
                    if (flags&FSHARP) { str = base_prefix + str; }
                  } else {
                    str = '..' + str;
                    if (flags&FSHARP) { str = base_prefix + str; }
                    while (str.length < width) { str = ' ' + str; }
                  }
                }
              }
            }
            if (format_string.charAt(i) === format_string.charAt(i).toUpperCase()) {
              str = str.toUpperCase();
            }
            break format_sequence;

          case 'f':
          case 'e':
          case 'E':
          case 'g':
          case 'G':
            arg = #{Float(`GET_ARG()`)};
            if (arg >= 0 || isNaN(arg)) {
              if (arg === Infinity) {
                str = 'Inf';
              } else {
                switch (format_string.charAt(i)) {
                case 'f':
                  str = arg.toFixed(precision === -1 ? 6 : precision);
                  break;
                case 'e':
                case 'E':
                  str = arg.toExponential(precision === -1 ? 6 : precision);
                  break;
                case 'g':
                case 'G':
                  str = arg.toExponential();
                  exponent = parseInt(str.split('e')[1], 10);
                  if (!(exponent < -4 || exponent >= (precision === -1 ? 6 : precision))) {
                    str = arg.toPrecision(precision === -1 ? (flags&FSHARP ? 6 : undefined) : precision);
                  }
                  break;
                }
              }
              if (flags&FMINUS) {
                if (flags&FPLUS || flags&FSPACE) { str = (flags&FPLUS ? '+' : ' ') + str; }
                while (str.length < width) { str = str + ' '; }
              } else {
                if (flags&FZERO && arg !== Infinity && !isNaN(arg)) {
                  while (str.length < width - ((flags&FPLUS || flags&FSPACE) ? 1 : 0)) { str = '0' + str; }
                  if (flags&FPLUS || flags&FSPACE) { str = (flags&FPLUS ? '+' : ' ') + str; }
                } else {
                  if (flags&FPLUS || flags&FSPACE) { str = (flags&FPLUS ? '+' : ' ') + str; }
                  while (str.length < width) { str = ' ' + str; }
                }
              }
            } else {
              if (arg === -Infinity) {
                str = 'Inf';
              } else {
                switch (format_string.charAt(i)) {
                case 'f':
                  str = (-arg).toFixed(precision === -1 ? 6 : precision);
                  break;
                case 'e':
                case 'E':
                  str = (-arg).toExponential(precision === -1 ? 6 : precision);
                  break;
                case 'g':
                case 'G':
                  str = (-arg).toExponential();
                  exponent = parseInt(str.split('e')[1], 10);
                  if (!(exponent < -4 || exponent >= (precision === -1 ? 6 : precision))) {
                    str = (-arg).toPrecision(precision === -1 ? (flags&FSHARP ? 6 : undefined) : precision);
                  }
                  break;
                }
              }
              if (flags&FMINUS) {
                str = '-' + str;
                while (str.length < width) { str = str + ' '; }
              } else {
                if (flags&FZERO && arg !== -Infinity) {
                  while (str.length < width - 1) { str = '0' + str; }
                  str = '-' + str;
                } else {
                  str = '-' + str;
                  while (str.length < width) { str = ' ' + str; }
                }
              }
            }
            if (format_string.charAt(i) === format_string.charAt(i).toUpperCase() && arg !== Infinity && arg !== -Infinity && !isNaN(arg)) {
              str = str.toUpperCase();
            }
            str = str.replace(/([eE][-+]?)([0-9])$/, '$10$2');
            break format_sequence;

          case 'a':
          case 'A':
            // Not implemented because there are no specs for this field type.
            #{raise NotImplementedError, '`A` and `a` format field types are not implemented in Opal yet'}

          case 'c':
            arg = GET_ARG();
            if (#{`arg`.respond_to?(:to_ary)}) { arg = #{`arg`.to_ary}[0]; }
            if (#{`arg`.respond_to?(:to_str)}) {
              str = #{`arg`.to_str};
            } else {
              str = String.fromCharCode(#{Opal.coerce_to(`arg`, Integer, :to_int)});
            }
            if (str.length !== 1) {
              #{raise ArgumentError, '%c requires a character'}
            }
            if (flags&FMINUS) {
              while (str.length < width) { str = str + ' '; }
            } else {
              while (str.length < width) { str = ' ' + str; }
            }
            break format_sequence;

          case 'p':
            str = #{`GET_ARG()`.inspect};
            if (precision !== -1) { str = str.slice(0, precision); }
            if (flags&FMINUS) {
              while (str.length < width) { str = str + ' '; }
            } else {
              while (str.length < width) { str = ' ' + str; }
            }
            break format_sequence;

          case 's':
            str = #{`GET_ARG()`.to_s};
            if (precision !== -1) { str = str.slice(0, precision); }
            if (flags&FMINUS) {
              while (str.length < width) { str = str + ' '; }
            } else {
              while (str.length < width) { str = ' ' + str; }
            }
            break format_sequence;

          default:
            #{raise ArgumentError, "malformed format string - %#{`format_string.charAt(i)`}"}
          }
        }

        if (str === undefined) {
          #{raise ArgumentError, 'malformed format string - %'}
        }

        result += format_string.slice(begin_slice, end_slice) + str;
        begin_slice = i + 1;
      }

      if (#{$DEBUG} && pos_arg_num >= 0 && seq_arg_num < args.length) {
        #{raise ArgumentError, 'too many arguments for format string'}
      }

      return result + format_string.slice(begin_slice);
    }
  end

  def hash
    __id__
  end

  def initialize_copy(other)
  end

  def inspect
    to_s
  end

  def instance_of?(klass)
    %x{
      if (!klass.$$is_class && !klass.$$is_module) {
        #{raise TypeError, 'class or module required'};
      }

      return self.$$class === klass;
    }
  end

  def instance_variable_defined?(name)
    name = Opal.instance_variable_name!(name)

    `Opal.hasOwnProperty.call(self, name.substr(1))`
  end

  def instance_variable_get(name)
    name = Opal.instance_variable_name!(name)

    %x{
      var ivar = self[Opal.ivar(name.substr(1))];

      return ivar == null ? nil : ivar;
    }
  end

  def instance_variable_set(name, value)
    name = Opal.instance_variable_name!(name)

    `self[Opal.ivar(name.substr(1))] = value`
  end

  def remove_instance_variable(name)
    name = Opal.instance_variable_name!(name)

    %x{
      var key = Opal.ivar(name.substr(1)),
          val;
      if (self.hasOwnProperty(key)) {
        val = self[key];
        delete self[key];
        return val;
      }
    }

    raise NameError, "instance variable #{name} not defined"
  end

  def instance_variables
    %x{
      var result = [], ivar;

      for (var name in self) {
        if (self.hasOwnProperty(name) && name.charAt(0) !== '$') {
          if (name.substr(-1) === '$') {
            ivar = name.slice(0, name.length - 1);
          } else {
            ivar = name;
          }
          result.push('@' + ivar);
        }
      }

      return result;
    }
  end

  def Integer(value, base = undefined)
    %x{
      var i, str, base_digits;

      if (!value.$$is_string) {
        if (base !== undefined) {
          #{raise ArgumentError, "base specified for non string value"}
        }
        if (value === nil) {
          #{raise TypeError, "can't convert nil into Integer"}
        }
        if (value.$$is_number) {
          if (value === Infinity || value === -Infinity || isNaN(value)) {
            #{raise FloatDomainError, value}
          }
          return Math.floor(value);
        }
        if (#{value.respond_to?(:to_int)}) {
          i = #{value.to_int};
          if (i !== nil) {
            return i;
          }
        }
        return #{Opal.coerce_to!(value, Integer, :to_i)};
      }

      if (value === "0") {
        return 0;
      }

      if (base === undefined) {
        base = 0;
      } else {
        base = #{Opal.coerce_to(`base`, Integer, :to_int)};
        if (base === 1 || base < 0 || base > 36) {
          #{raise ArgumentError, "invalid radix #{base}"}
        }
      }

      str = value.toLowerCase();

      str = str.replace(/(\d)_(?=\d)/g, '$1');

      str = str.replace(/^(\s*[+-]?)(0[bodx]?)/, function (_, head, flag) {
        switch (flag) {
        case '0b':
          if (base === 0 || base === 2) {
            base = 2;
            return head;
          }
        case '0':
        case '0o':
          if (base === 0 || base === 8) {
            base = 8;
            return head;
          }
        case '0d':
          if (base === 0 || base === 10) {
            base = 10;
            return head;
          }
        case '0x':
          if (base === 0 || base === 16) {
            base = 16;
            return head;
          }
        }
        #{raise ArgumentError, "invalid value for Integer(): \"#{value}\""}
      });

      base = (base === 0 ? 10 : base);

      base_digits = '0-' + (base <= 10 ? base - 1 : '9a-' + String.fromCharCode(97 + (base - 11)));

      if (!(new RegExp('^\\s*[+-]?[' + base_digits + ']+\\s*$')).test(str)) {
        #{raise ArgumentError, "invalid value for Integer(): \"#{value}\""}
      }

      i = parseInt(str, base);

      if (isNaN(i)) {
        #{raise ArgumentError, "invalid value for Integer(): \"#{value}\""}
      }

      return i;
    }
  end

  def Float(value)
    %x{
      var str;

      if (value === nil) {
        #{raise TypeError, "can't convert nil into Float"}
      }

      if (value.$$is_string) {
        str = value.toString();

        str = str.replace(/(\d)_(?=\d)/g, '$1');

        //Special case for hex strings only:
        if (/^\s*[-+]?0[xX][0-9a-fA-F]+\s*$/.test(str)) {
          return #{Integer(`str`)};
        }

        if (!/^\s*[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?\s*$/.test(str)) {
          #{raise ArgumentError, "invalid value for Float(): \"#{value}\""}
        }

        return parseFloat(str);
      }

      return #{Opal.coerce_to!(value, Float, :to_f)};
    }
  end

  def Hash(arg)
    return {} if arg.nil? || arg == []
    return arg if Hash === arg
    return Opal.coerce_to!(arg, Hash, :to_hash)
  end

  def is_a?(klass)
    %x{
      if (!klass.$$is_class && !klass.$$is_module) {
        #{raise TypeError, 'class or module required'};
      }

      return Opal.is_a(self, klass);
    }
  end

  alias kind_of? is_a?

  def lambda(&block)
    `block.$$is_lambda = true`

    block
  end

  def load(file)
    file = Opal.coerce_to!(file, String, :to_str)
    `Opal.load(#{file})`
  end

  def loop
    return enum_for(:loop) { Float::INFINITY } unless block_given?

    while true do
      begin
        yield
      rescue StopIteration => e
        return e.result
      end
    end

    self
  end

  def nil?
    false
  end

  alias object_id __id__

  def printf(*args)
    if args.length > 0
      print format(*args)
    end

    nil
  end

  def proc(&block)
    unless block
      raise ArgumentError, "tried to create Proc object without a block"
    end

    `block.$$is_lambda = false`
    block
  end

  def puts(*strs)
    $stdout.puts(*strs)
  end

  def p(*args)
    args.each { |obj| $stdout.puts obj.inspect }

    args.length <= 1 ? args[0] : args
  end

  def print(*strs)
    $stdout.print(*strs)
  end

  def warn(*strs)
    $stderr.puts(*strs) unless $VERBOSE.nil? || strs.empty?
  end

  def raise(exception = undefined, string = nil, _backtrace = nil)
    %x{
      if (exception == null && #$! !== nil) {
        throw #$!;
      }
      if (exception == null) {
        exception = #{RuntimeError.new};
      }
      else if (exception.$$is_string) {
        exception = #{RuntimeError.new exception};
      }
      // using respond_to? and not an undefined check to avoid method_missing matching as true
      else if (exception.$$is_class && #{exception.respond_to?(:exception)}) {
        exception = #{exception.exception string};
      }
      else if (#{exception.kind_of?(Exception)}) {
        // exception is fine
      }
      else {
        exception = #{TypeError.new 'exception class/object expected'};
      }

      if (#$! !== nil) {
        Opal.exceptions.push(#$!);
      }

      #$! = exception;

      throw exception;
    }
  end

  alias fail raise

  def rand(max = undefined)
    %x{
      if (max === undefined) {
        return #{Random::DEFAULT.rand};
      }

      if (max.$$is_number) {
        if (max < 0) {
          max = Math.abs(max);
        }

        if (max % 1 !== 0) {
          max = max.$to_i();
        }

        if (max === 0) {
          max = undefined;
        }
      }
    }
    Random::DEFAULT.rand(max)
  end

  def respond_to?(name, include_all = false)
    return true if respond_to_missing?(name, include_all)

    %x{
      var body = self['$' + name];

      if (typeof(body) === "function" && !body.$$stub) {
        return true;
      }
    }

    false
  end

  def respond_to_missing?(method_name, include_all = false)
    false
  end

  def require(file)
    file = Opal.coerce_to!(file, String, :to_str)
    `Opal.require(#{file})`
  end

  def require_relative(file)
    Opal.try_convert!(file, String, :to_str)
    file = File.expand_path File.join(`Opal.current_file`, '..', file)

    `Opal.require(#{file})`
  end

  # `path` should be the full path to be found in registered modules (`Opal.modules`)
  def require_tree(path)
    path = File.expand_path(path)
    path = '' if path == '.'

    %x{
      for (var name in Opal.modules) {
        if (#{`name`.start_with?(path)}) {
          Opal.require(name);
        }
      }
    }

    nil
  end

  alias send        __send__
  alias public_send __send__

  def singleton_class
    `Opal.get_singleton_class(self)`
  end

  def sleep(seconds = nil)
    %x{
      if (seconds === nil) {
        #{raise TypeError, "can't convert NilClass into time interval"}
      }
      if (!seconds.$$is_number) {
        #{raise TypeError, "can't convert #{seconds.class} into time interval"}
      }
      if (seconds < 0) {
        #{raise ArgumentError, "time interval must be positive"}
      }
      var t = new Date();
      while (new Date() - t <= seconds * 1000);
      return seconds;
    }
  end

  alias sprintf format

  def srand(seed = Random.new_seed)
    Random.srand(seed)
  end

  def String(str)
    Opal.coerce_to?(str, String, :to_str) ||
      Opal.coerce_to!(str, String, :to_s)
  end

  def tap(&block)
    yield self
    self
  end

  def to_proc
    self
  end

  def to_s
    "#<#{self.class}:0x#{__id__.to_s(16)}>"
  end

  def catch(sym)
    yield
  rescue UncaughtThrowError => e
    return e.arg if e.sym == sym
    raise
  end

  def throw(*args)
    raise UncaughtThrowError.new(args)
  end

  # basic implementation of open, delegate to File.open
  def open(*args, &block)
    File.open(*args, &block)
  end
end

class Object
  include Kernel
end
