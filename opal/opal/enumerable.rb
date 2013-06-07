module Enumerable
  def all?(&block)
    %x{
      var result = true, proc;

      if (block !== null) {
        proc = function(obj) {
          var value;
          var args = [];
          for(var i = 0; i < arguments.length; i ++) {
            args[i] = arguments[i];
          }
          
          if ((value = block.apply(#{self}, args)) === __breaker) {
            return __breaker.$v;
          }
             
          if (value === false || value === null) {
            result = false;
            __breaker.$v = null;

            return __breaker;
          }
        }
      }
      else {
        proc = function(obj) {
          if ((obj === false || obj === null) && arguments.length < 2) {  
            result = false;
            __breaker.$v = null;

            return __breaker;
          }
        }
      }

      #{self}.$each._p = proc;
      #{self}.$each();

      return result;
    }
  end

  def any?(&block) 
    %x{
      var result = false, proc;

      if (block !== null) {
        proc = function(obj) {
          var value;
          var args = [];
          for(var i = 0; i < arguments.length; i ++) {
            args[i] = arguments[i];
          }
          
          if ((value = block.apply(#{self}, args)) === __breaker) {
            return __breaker.$v;
          }

          if (value !== false && value !== null) {
            result       = true;
            __breaker.$v = null;

            return __breaker;
          }
        }
      }
      else {
        proc = function(obj) {
          if ((obj !== false && obj !== null) || arguments.length >= 2) {
            result      = true;
            __breaker.$v = null;
            
            return __breaker;
          }
        }
      }

      #{self}.$each._p = proc;
      #{self}.$each();

      return result;
    }
  end

  def collect(&block)
    %x{
      var result = [];

      var proc = function() {
        var obj = __slice.call(arguments), value;

        if ((value = block.apply(null, obj)) === __breaker) {
          return __breaker.$v;
        }

        result.push(value);
      };

      #{self}.$each._p = proc;
      #{self}.$each();

      return result;
    }
  end

  def reduce(object = undefined, &block)
    %x{
      var result = #{object} == undefined ? 0 : #{object};

      var proc = function() {
        var obj = __slice.call(arguments), value;

        if ((value = block.apply(null, [result].concat(obj))) === __breaker) {
          result = __breaker.$v;
          __breaker.$v = null;

          return __breaker;
        }

        result = value;
      };

      #{self}.$each._p = proc;
      #{self}.$each();

      return result;
    }
  end

  def count(object = undefined, &block)
    %x{
      var result = 0;

      if (object !== undefined) {
        block = function(obj) { return #{ `obj` == `object` }; };
      }
      else if (block === null) {
        block = function() { return true; };
      }

      var proc = function(obj) {
        var value;

        if ((value = block(obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== null) {
          result++;
        }
      }

      #{self}.$each._p = proc;
      #{self}.$each();

      return result;
    }
  end

  def detect(ifnone = undefined, &block)
    %x{
      var result = null;

      #{self}.$each._p = function(obj) {
        var value;

        if ((value = block(obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== null) {
          result      = obj;
          __breaker.$v = null;

          return __breaker;
        }
      };

      #{self}.$each();

      if (result !== null) {
        return result;
      }

      if (typeof(ifnone) === 'function') {
        return #{ ifnone.call };
      }

      return ifnone == null ? null : ifnone;
    }
  end

  def drop(number)
    %x{
      var result  = [],
          current = 0;

      #{self}.$each._p = function(obj) {
        if (number < current) {
          result.push(e);
        }

        current++;
      };

      #{self}.$each()

      return result;
    }
  end

  def drop_while(&block)
    %x{
      var result = [];

      #{self}.$each._p = function(obj) {
        var value;

        if ((value = block(obj)) === __breaker) {
          return __breaker;
        }

        if (value === false || value === null) {
          result.push(obj);
          return value;
        }

        return __breaker;
      };

      #{self}.$each();

      return result;
    }
  end

  def each_slice(n, &block)
    %x{
      var all = [];

      #{self}.$each._p = function(obj) {
        all.push(obj);

        if (all.length == n) {
          block(all.slice(0));
          all = [];
        }
      };

      #{self}.$each();

      // our "last" group, if smaller than n then wont have been yielded
      if (all.length > 0) {
        block(all.slice(0));
      }

      return null;
    }
  end

  def each_with_index(&block)
    %x{
      var index = 0;

      #{self}.$each._p = function(obj) {
        var value;

        if ((value = block(obj, index)) === __breaker) {
          return __breaker.$v;
        }

        index++;
      };
      #{self}.$each();

      return null;
    }
  end

  def each_with_object(object, &block)
    %x{
      #{self}.$each._p = function(obj) {
        var value;

        if ((value = block(obj, object)) === __breaker) {
          return __breaker.$v;
        }
      };

      #{self}.$each();

      return object;
    }
  end

  def entries
    %x{
      var result = [];

      #{self}.$each._p = function(obj) {
        result.push(obj);
      };

      #{self}.$each();

      return result;
    }
  end

  alias find detect

  def find_all(&block)
    %x{
      var result = [];

      #{self}.$each._p = function(obj) {
        var value;

        if ((value = block(obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== null) {
          result.push(obj);
        }
      };

      #{self}.$each();

      return result;
    }
  end

  def find_index(object = undefined, &block)
    %x{
      var proc, result = null, index = 0;

      if (object != null) {
        proc = function (obj) {
          if (#{ `obj` == `object` }) {
            result = index;
            return __breaker;
          }
          index += 1;
        };
      }
      else {
        proc = function(obj) {
          var value;

          if ((value = block(obj)) === __breaker) {
            return __breaker.$v;
          }

          if (value !== false && value !== null) {
            result     = index;
            __breaker.$v = index;

            return __breaker;
          }
          index += 1;
        };
      }

      #{self}.$each._p = proc;
      #{self}.$each();

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

      #{self}.$each._p = proc;
      #{self}.$each();

      return result;
    }
  end

  def grep(pattern, &block)
    %x{
      var result = [];

      #{self}.$each._p = (block !== null
        ? function(obj) {
            var value = #{pattern === `obj`};

            if (value !== false && value !== null) {
              if ((value = block(obj)) === __breaker) {
                return __breaker.$v;
              }

              result.push(value);
            }
          }
        : function(obj) {
            var value = #{pattern === `obj`};

            if (value !== false && value !== null) {
              result.push(obj);
            }
          });

      #{self}.$each();

      return result;
    }
  end

  def group_by(&block)
    hash = Hash.new { |h, k| h[k] = [] }

    each do |el|
      hash[block.call(el)] << el
    end

    hash
  end

  alias map collect

  def max(&block)
    %x{
      var proc, result;
      var arg_error = false;
      if (block !== null) {
        proc = function(obj) {
          if (result == undefined) {
            result = obj;
          }
          else if ((value = block(obj, result)) === __breaker) {
            result = __breaker.$v;
            return __breaker;
          }
          else {
            if (value > 0) {
              result = obj;
            }
            __breaker.$v = null;
          }
        }
      }
      else {
        proc = function(obj) {
          var modules = obj.$class().$included_modules;
          if (modules == undefined || modules.length == 0 || modules.indexOf(Opal.Comparable) == -1) {
            arg_error = true;
            return __breaker;
          }
          if (result == undefined || obj > result) {
            result = obj;
          }
        }
      }

      #{self}.$each._p = proc;
      #{self}.$each();

      if (arg_error) {
        #{raise ArgumentError, "Array#max"};
      }

      return (result == undefined ? null : result);
    }
  end

  def min(&block)
    %x{
      var proc, result;
      var arg_error = false;
      if (block !== null) {
        proc = function(obj) {
          if (result == undefined) {
            result = obj;
          }
          else if ((value = block(obj, result)) === __breaker) {
            result = __breaker.$v;
            return __breaker;
          }
          else {
            if (value < 0) {
              result = obj;
            }
            __breaker.$v = null;
          }
        }
      }
      else {
        proc = function(obj) {
          var modules = obj.$class().$included_modules;
          if (modules == undefined || modules.length == 0 || modules.indexOf(Opal.Comparable) == -1) {
            arg_error = true;
            return __breaker;
          }
          if (result == undefined || obj < result) {
            result = obj;
          }
        }
      }

      #{self}.$each._p = proc;
      #{self}.$each();

      if (arg_error) {
        #{raise ArgumentError, "Array#min"};
      }

      return (result == undefined ? null : result);
    }
  end

  def none?(&block)
    %x{
      var result = true, proc;

      if (block !== null) {
        proc = function(obj) {
          var value;
          var args = [];
          for(var i = 0; i < arguments.length; i ++) {
            args[i] = arguments[i];
          }
          
          if ((value = block.apply(#{self}, args)) === __breaker) {
            return __breaker.$v;
          }
             
          if (value !== false && value !== null) {
            result = false;
            __breaker.$v = null;

            return __breaker;
          }
        }
      }
      else {
        proc = function(obj) {
          if (arguments.length == 1 && (obj !== false && obj !== null)) {
            result = false;
            __breaker.$v = null;

            return __breaker;
          }
          else {
            for (var i = 0, length = arguments.length; i < length; i++) {
              if (arguments[i] !== false && arguments[i] !== null) {
                result = false;
                __breaker.$v = null;

                return __breaker;
              }
            }
          }
        };
      }

      #{self}.$each._p = proc;
      #{self}.$each();
      
      return result;
    }
  end

  alias select find_all

  alias take first

  alias to_a entries

  alias inject reduce
end

