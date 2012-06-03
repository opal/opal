module Enumerable
  def all?(&block)
    %x{
      var result = true, proc;

      if (block != null) {
        proc = function(obj) {
          var value;

          if ((value = block.call(__context, obj)) === __breaker) {
            return __breaker.$v;
          }

          if (value === false || value == null) {
            result = false;
            __breaker.$v = null;

            return __breaker;
          }
        }
      }
      else {
        proc = function(obj) {
          if (obj === false || obj == null) {
            result = false;
            __breaker.$v = null;

            return __breaker;
          }
        }
      }

      this.$each._p = proc;
      this.$each();

      return result;
    }
  end

  def any?(&block)
    %x{
      var result = false, proc;

      if (block != null) {
        proc = function(obj) {
          var value;

          if ((value = block.call(__context, obj)) === __breaker) {
            return __breaker.$v;
          }

          if (value !== false && value != null) {
            result       = true;
            __breaker.$v = null;

            return __breaker;
          }
        }
      }
      else {
        proc = function(obj) {
          if (obj !== false && obj != null) {
            result      = true;
            __breaker.$v = null;

            return __breaker;
          }
        }
      }

      this.$each._p = proc;
      this.$each();

      return result;
    }
  end

  def collect(&block)
    return enum_for :collect unless block_given?

    %x{
      var result = [];

      var proc = function() {
        var obj = __slice.call(arguments), value;

        if ((value = block.apply(__context, obj)) === __breaker) {
          return __breaker.$v;
        }

        result.push(value);
      };

      this.$each._p = proc;
      this.$each();

      return result;
    }
  end

  def count(object = undefined, &block)
    %x{
      var result = 0;

      if (block == null) {
        if (object == null) {
          block = function() { return true; };
        }
        else {
          block = function(obj) { return #{`obj` == `object`}; };
        }
      }

      var proc = function(obj) {
        var value;

        if ((value = block.call(__context, obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value != null) {
          result++;
        }
      }

      this.$each._p = proc;
      this.$each();

      return result;
    }
  end

  def detect(ifnone = undefined, &block)
    return enum_for :detect, ifnone unless block

    %x{
      var result = null;

      this.$each._p = function(obj) {
        var value;

        if ((value = block.call(__context, obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value != null) {
          result      = obj;
          __breaker.$v = null;

          return __breaker;
        }
      };

      this.$each();

      if (result !=  null) {
        return result;
      }

      if (typeof(ifnone) === 'function') {
        return ifnone.$call();
      }

      return ifnone === undefined ? null : ifnone;
    }
  end

  def drop(number)
    %x{
      var result  = [],
          current = 0;

      this.$each._p = function(obj) {
        if (number < current) {
          result.push(e);
        }

        current++;
      };

      this.$each();

      return result;
    }
  end

  def drop_while(&block)
    return enum_for :drop_while unless block

    %x{
      var result = [];

      this.$each._p = function(obj) {
        var value;

        if ((value = block.call(__context, obj)) === __breaker) {
          return __breaker;
        }

        if (value !== false && value != null) {
          result.push(obj);
        }
        else {
          return __breaker;
        }
      };

      this.$each();

      return result;
    }
  end

  def each_with_index(&block)
    return enum_for :each_with_index unless block

    %x{
      var index = 0;

      this.$each._p = function(obj) {
        var value;

        if ((value = block.call(__context, obj, index)) === __breaker) {
          return __breaker.$v;
        }

        index++;
      };

      this.$each();

      return null;
    }
  end

  def each_with_object(object, &block)
    return enum_for :each_with_object unless block

    %x{
      this.$each._p = function(obj) {
        var value;

        if ((value = block.call(__context, obj, object)) === __breaker) {
          return __breaker.$v;
        }
      };

      this.$each();

      return object;
    }
  end

  def entries
    %x{
      var result = [];

      this.$each._p = function(obj) {
        result.push(obj);
      };

      this.$each();

      return result;
    }
  end

  alias find detect

  def find_all(&block)
    return enum_for :find_all unless block

    %x{
      var result = [];

      this.$each._p = function(obj) {
        var value;

        if ((value = block.call(__context, obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value != null) {
          //result      = obj;
          //__breaker.$v = null;

          //return __breaker;
          result.push(obj);
        }
      };

      this.$each();

      return result;
    }
  end

  def find_index(object = undefined, &block)
    %x{
      var proc, result = null, index = 0;

      if (object != null) {
        proc = function (obj) { 
          if (obj.$eq$(object)) {
            result = index;
            return __breaker;
          }
          index += 1;
        };
      }
      else if (block == null) {
        return this.$enum_for("find_index");
      } else {
        proc = function(obj) {
          var value;

          if ((value = block.call(__context, obj)) === __breaker) {
            return __breaker.$v;
          }

          if (value !== false && value != null) {
            result     = index;
            __breaker.$v = index;

            return __breaker;
          }
          index += 1;
        };
      }

      this.$each._p = proc;

      this.$each();

      return result;
    }
  end

  def first(number = undefined)
    %x{
      var result = [],
          current = 0,
          proc;

      if (number == null) {
        result = null;
        proc = function(obj) {
            result = obj; return __breaker;
          };
      } else {
        proc = function(obj) {
            if (number <= current) {
              return __breaker;
            }

            result.push(obj);

            current++;
          };
      }

      this.$each._p = proc;

      this.$each();

      return result;
    }
  end

  def grep(pattern, &block)
    %x{
      var result = [];

      this.$each._p = (block != null
        ? function(obj) {
            var value = pattern.$eqq$(obj);

            if (value !== false && value != null) {
              if ((value = block.call(__context, obj)) === __breaker) {
                return __breaker.$v;
              }

              result.push(value);
            }
          }
        : function(obj) {
            var value = pattern.$eqq$(obj);

            if (value !== false && value != null) {
              result.push(obj);
            }
          });

      this.$each();

      return result;
    }
  end

  alias take first

  alias to_a entries
end
