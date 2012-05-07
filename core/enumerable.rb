module Enumerable
  def all?(&block)
    %x{
      var result = true;

      this.$each(block !== nil
        ? function(y, obj) {
            var value;

            if ((value = $yield.call($context, null, obj)) === $breaker) {
              return $breaker.$v;
            }

            if (value === false || value === nil) {
              result      = false;
              $breaker.$v = nil;

              return $breaker;
            }
          }
        : function(y, obj) {
            if (obj === false || obj === nil) {
              result      = false;
              $breaker.$v = nil;

              return $breaker;
            }
          });


      return result;
    }
  end

  def any?(&block)
    %x{
      var result = false;

      this.$each(block !== nil
        ? function(y, obj) {
            var value;

            if ((value = $yield.call($context, null, obj)) === $breaker) {
              return $breaker.$v;
            }

            if (value !== false && value !== nil) {
              result      = true;
              $breaker.$v = nil;

              return $breaker;
            }
          }
        : function(y, obj) {
            if (obj !== false && obj !== nil) {
              result      = true;
              $breaker.$v = nil;

              return $breaker;
            }
          });

      return result;
    }
  end

  def collect(&block)
    return enum_for :collect unless block_given?

    %x{
      var result = [];

      this.$each(function () {
        var obj = _superlice.call(arguments, 1),
            value;

        if ((value = $yield.apply($context, null, obj)) === $breaker) {
          return $breaker.$v;
        }

        result.push(value);
      });

      return result;
    }
  end

  def count(object = undefined, &block)
    %x{
      var result = 0;

      if (block === nil) {
        if (object === undefined) {
          $yield = function() { return true; };
        }
        else {
          $yield = function(y, obj) { return #{`obj` == `object`}; };
        }
      }

      this.$each(function(y, obj) {
        var value;

        if ((value = $yield.call($context, null, obj)) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          result++;
        }
      });

      return result;
    }
  end

  def detect(ifnone = undefined, &block)
    return enum_for :detect, ifnone unless block

    %x{
      var result = nil;

      this.$each(function(y, obj) {
        var value;

        if ((value = $yield.call($context, null, obj)) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          result      = obj;
          $breaker.$v = nil;

          return $breaker;
        }
      });

      if (result !== nil) {
        return result;
      }

      if (typeof(ifnone) === 'function') {
        return ifnone.$call();
      }

      return ifnone === undefined ? nil : ifnone;
    }
  end

  def drop(number)
    raise NotImplementedError

    %x{
      var result  = [],
          current = 0;

      this.$each(function(y, obj) {
        if (number < current) {
          result.push(e);
        }

        current++;
      });

      return result;
    }
  end

  def drop_while(&block)
    return enum_for :drop_while unless block

    %x{
      var result = [];

      this.$each.$P = function(y, obj) {
        var value;

        if ((value = $yield.call($context, null, obj)) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          result.push(obj);
        }
        else {
          return $breaker;
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

      this.$each(function(y, obj) {
        var value;

        if ((value = $yield.call($context, null, obj, index)) === $breaker) {
          return $breaker.$v;
        }

        index++;
      });

      return nil;
    }
  end

  def entries
    result = []

    each {|*args|
      result.push args.length == 1 ? args.first : args
    }

    result
  end

  alias find detect

  def find_index(object = undefined, &block)
    return enum_for :find_index, object unless block

    %x{
      if (object !== undefined) {
        $yield = function (y, obj) { return obj.$eq$(null, object); };
      }

      var result = nil;

      this.$each_with_index(function(y, obj, index) {
        var value;

        if ((value = $yield.call($context, null, obj)) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          result     = obj;
          breaker.$v = index;

          return $breaker;
        }
      });

      return result;
    }
  end

  def first(number = undefined)
    %x{
      var result = [],
          current = 0;

      this.$each(number === undefined
        ? function(y, obj) {
            result = obj; return $breaker;
          }
        : function(y, obj) {
            if (number <= current) {
              return $breaker;
            }

            result.push(obj);

            current++;
          });

      return result;
    }
  end

  def grep(pattern, &block)
    %x{
      var result = [];

      this.$each(block !== nil
        ? function(y, obj) {
            var value = pattern.$eqq$(null, obj);

            if (value !== false && value !== nil) {
              if ((value = $yield.call($context, null, obj)) === $breaker) {
                return $breaker.$v;
              }

              result.push(obj);
            }
          }
        : function(y, obj) {
            var value = pattern.$eqq$(null, obj);

            if (value !== false && value !== nil) {
              ary.push(obj);
            }
          });

      return result;
    }
  end

  alias take first

  alias to_a entries
end
