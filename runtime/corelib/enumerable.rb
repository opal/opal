module Enumerable
  def all?(&block)
    %x{
      var result = true;

      this.$each.$P = block !== nil
        ? function(obj) {
            var value;

            if ((value = $yield.call($context, obj)) === $breaker) {
              return $breaker.$v;
            }

            if (value === false || value === nil) {
              result      = false;
              $breaker.$v = nil;

              return $breaker;
            }
          }
        : function(obj) {
            if (obj === false || obj === nil) {
              result      = false;
              $breaker.$v = nil;

              return $breaker;
            }
          };

      this.$each();

      return result;
    }
  end

  def any?(&block)
    %x{
      var result = false;

      this.$each.$P = block !== nil
        ? function(obj) {
            var value;

            if ((value = $yield.call($context, obj)) === $breaker) {
              return $breaker.$v;
            }

            if (value !== false && value !== nil) {
              result      = true;
              $breaker.$v = nil;

              return $breaker;
            }
          }
        : function(obj) {
            if (obj !== false && obj !== nil) {
              result      = true;
              $breaker.$v = nil;

              return $breaker;
            }
          };

      this.$each();

      return result;
    }
  end

  def collect(&block)
    return enum_for :collect unless block_given?

    %x{
      var result = [];

      this.$each.$P = function () {
        var obj = $slice.call(arguments),
            value;

        if ((value = $yield.apply($context, obj)) === $breaker) {
          return $breaker.$v;
        }

        result.push(value);
      };

      this.$each();

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
          $yield = function(obj) { return #{`obj` == `object`}; };
        }
      }

      this.$each.$P = function(obj) {
        var value;

        if ((value = $yield.call($context, obj)) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          result++;
        }
      };

      this.$each();

      return result;
    }
  end

  def detect(ifnone = undefined, &block)
    return enum_for :detect, ifnone unless block

    %x{
      var result = nil;

      this.$each.$P = function(obj) {
        var value;

        if ((value = $yield.call($context, obj)) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          result      = obj;
          $breaker.$v = nil;

          return $breaker;
        }
      };

      this.$each();

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

      this.$each.$P = function(obj) {
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

      this.$each.$P = function(obj) {
        var value;

        if ((value = $yield.call($context, obj)) === $breaker) {
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

      this.$each.$P = function(obj) {
        var value;

        if ((value = $yield.call($context, obj, index)) === $breaker) {
          return $breaker.$v;
        }

        index++;
      };

      this.$each();

      return nil;
    }
  end

  def entries
    %x{
      var result = [];

      this.$each.$P = function(obj) { return result.push(obj); };
      this.$each();

      return result;
    }
  end

  alias find detect

  def find_index(object = undefined, &block)
    return enum_for :find_index, object unless block

    %x{
      if (object !== undefined) {
        $yield = function (iter, obj) { return obj.$eq$(object); };
      }

      var result = nil;

      this.$each_with_index.$P = function(obj, index) {
        var value;

        if ((value = $yield.call($context, obj)) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          result     = obj;
          breaker.$v = index;

          return $breaker;
        }
      };

      this.$each_with_index();

      return result;
    }
  end

  def first(number = undefined)
    %x{
      var result = [],
          current = 0;

      this.$each.$P = number === undefined
        ? function(obj) {
            result = obj; return $breaker;
          }
        : function(obj) {
            if (number <= current) {
              return $breaker;
            }

            result.push(obj);

            current++;
          };

      this.$each();

      return result;
    }
  end

  def grep(pattern, &block)
    %x{
      var result = [];

      this.$each.$P = block !== nil
        ? function(obj) {
            var value = pattern.$eqq$(obj);

            if (value !== false && value !== nil) {
              if ((value = $yield.call($context, obj)) === $breaker) {
                return $breaker.$v;
              }

              result.push(obj);
            }
          }
        : function(obj) {
            var value = pattern.$eqq$(obj);

            if (value !== false && value !== nil) {
              ary.push(obj);
            }
          };

      this.$each();

      return result;
    }
  end

  alias to_a entries
end
