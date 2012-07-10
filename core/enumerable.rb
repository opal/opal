module Enumerable
  def all?(&block)
    %x{
      var result = true, proc, each = #{self}.$m.each;

      if (block !== nil) {
        proc = function(s, m, obj) {
          var value;

          if ((value = block(__context, '', obj)) === __breaker) {
            return __breaker.$v;
          }

          if (value === false || value === nil) {
            result = false;
            __breaker.$v = nil;

            return __breaker;
          }
        }
      }
      else {
        proc = function(s, m, obj) {
          if (obj === false || obj === nil) {
            result = false;
            __breaker.$v = nil;

            return __breaker;
          }
        }
      }

      each._p = proc;
      each(#{self}, 'each');

      return result;
    }
  end

  def any?(&block)
    %x{
      var result = false, proc, each = #{self}.$m.each;

      if (block !== nil) {
        proc = function(s, m, obj) {
          var value;

          if ((value = block(__context, '', obj)) === __breaker) {
            return __breaker.$v;
          }

          if (value !== false && value !== nil) {
            result       = true;
            __breaker.$v = nil;

            return __breaker;
          }
        }
      }
      else {
        proc = function(s, m, obj) {
          if (obj !== false && obj !== nil) {
            result      = true;
            __breaker.$v = nil;

            return __breaker;
          }
        }
      }

      each._p = proc;
      each(#{self}, 'each');

      return result;
    }
  end

  def collect(&block)
    return enum_for :collect unless block_given?

    %x{
      var result = [], each = #{self}.$m.each;

      var proc = function() {
        var obj = __slice.call(arguments, 2), value;

        if ((value = block.apply(null, [__context, ''].concat(obj))) === __breaker) {
          return __breaker.$v;
        }

        result.push(value);
      };

      each._p = proc;
      each(#{self}, 'each');

      return result;
    }
  end

  def count(object, &block)
    %x{
      var result = 0, each = #{self}.$m.each;

      if (object != null) {
        block = function(s, m, obj) { return #{ `obj` == `object` }; };
      }
      else if (block === nil) {
        block = function() { return true; };
      }

      var proc = function(s, m, obj) {
        var value;

        if ((value = block(__context, '', obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          result++;
        }
      }

      each._p = proc;
      each(#{self}, 'each');

      return result;
    }
  end

  def detect(ifnone, &block)
    return enum_for :detect, ifnone unless block_given?

    %x{
      var result = nil, each = #{self}.$m.each;

      each._p = function(s, m, obj) {
        var value;

        if ((value = block(__context, '', obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          result      = obj;
          __breaker.$v = nil;

          return __breaker;
        }
      };

      each(#{self}, '');

      if (result !== nil) {
        return result;
      }

      if (typeof(ifnone) === 'function') {
        return #{ ifnone.call };
      }

      return ifnone == null ? nil : ifnone;
    }
  end

  def drop(number)
    %x{
      var result  = [],
          current = 0,
          each    = #{self}.$m.each;

      each._p = function(s, m, obj) {
        if (number < current) {
          result.push(e);
        }

        current++;
      };

      each(#{self}, '');

      return result;
    }
  end

  def drop_while(&block)
    return enum_for :drop_while unless block_given?

    %x{
      var result = [], each = #{self}.$m.each;

      each._p = function(s, m, obj) {
        var value;

        if ((value = block(__context, '', obj)) === __breaker) {
          return __breaker;
        }

        if (value === false || value === nil) {
          result.push(obj);
          return value;
        }
        
        
        return __breaker;
      };

      each(#{self}, '');

      return result;
    }
  end

  def each_with_index(&block)
    return enum_for :each_with_index unless block_given?

    %x{
      var index = 0, each = #{self}.$m.each;

      each._p = function(s, m, obj) {
        var value;

        if ((value = block(__context, '', obj, index)) === __breaker) {
          return __breaker.$v;
        }

        index++;
      };

      each(#{self}, '');

      return nil;
    }
  end

  def each_with_object(object, &block)
    return enum_for :each_with_object unless block_given?

    %x{
      var each = #{self}.$m.each;

      each._p = function(s, m, obj) {
        var value;

        if ((value = block(__context, '', obj, object)) === __breaker) {
          return __breaker.$v;
        }
      };

      each(#{self}, '');

      return object;
    }
  end

  def entries
    %x{
      var result = [], each = #{self}.$m.each;

      each._p = function(m, s, obj) {
        result.push(obj);
      };

      each(#{self}, '');

      return result;
    }
  end

  alias find detect

  def find_all(&block)
    return enum_for :find_all unless block_given?

    %x{
      var result = [], each = #{self}.$m.each;

      each._p = function(s, m, obj) {
        var value;

        if ((value = block(__context, '', obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          result.push(obj);
        }
      };

      each(#{self}, '');

      return result;
    }
  end

  def find_index(object, &block)
    %x{
      var proc, result = nil, index = 0, each = #{self}.$m.each;

      if (object != null) {
        proc = function (s, m, obj) { 
          if (#{ `obj` == `object` }) {
            result = index;
            return __breaker;
          }
          index += 1;
        };
      }
      else if (block === nil) {
        return #{ enum_for 'find_index' };
      } else {
        proc = function(s, m, obj) {
          var value;

          if ((value = block(__context, '', obj)) === __breaker) {
            return __breaker.$v;
          }

          if (value !== false && value !== nil) {
            result     = index;
            __breaker.$v = index;

            return __breaker;
          }
          index += 1;
        };
      }

      #{self}.$m.each._p = proc;
      #{self}.$m.each(#{self}, '');

      return result;
    }
  end

  def first(number)
    %x{
      var result = [],
          current = 0,
          proc,
          each = #{self}.$m.each;

      if (number == null) {
        result = nil;
        proc = function(s, m, obj) {
            result = obj; return __breaker;
          };
      } else {
        proc = function(s, m, obj) {
            if (number <= current) {
              return __breaker;
            }

            result.push(obj);

            current++;
          };
      }

      each._p = proc;
      each(#{self}, '');

      return result;
    }
  end

  def grep(pattern, &block)
    %x{
      var result = [], each = #{self}.$m.each;

      each._p = (block !== nil
        ? function(s, m, obj) {
            var value = #{pattern === `obj`};

            if (value !== false && value !== nil) {
              if ((value = block(__context, '', obj)) === __breaker) {
                return __breaker.$v;
              }

              result.push(value);
            }
          }
        : function(s, m, obj) {
            var value = #{pattern === `obj`};

            if (value !== false && value !== nil) {
              result.push(obj);
            }
          });

      each(#{self}, '');

      return result;
    }
  end

  alias take first

  alias to_a entries
end