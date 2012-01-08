module Enumerable
  def all?(&block)
    %x{
      var result = true, each = this.m$each;

      if (block !== nil) {
        each.$P = function(obj) {
          var value;

          if ((value = $yield.call($context, obj)) === $breaker) {
            return $breaker.$v;
          }

          if (value === false || value === nil) {
            result      = false;
            $breaker.$v = nil;

            return $breaker;
          }
        };
      }
      else {
        each.$P = function(obj) {
          if (obj === false || obj === nil) {
            result      = false;
            $breaker.$v = nil;

            return $breaker;
          }
        };
      }

      each.call(this);

      return result;
    }
  end

  def any?(&block)
    %x{
      var result = false, each = this.m$each;

      if (block !== nil) {
        each.$P = function(obj) {
          var value;

          if ((value = $yield.call($context, obj)) === $breaker) {
            return $breaker.$v;
          }

          if (value !== false && value !== nil) {
            result      = true;
            $breaker.$v = nil;

            return $breaker;
          }
        };
      }
      else {
        each.$P = function(obj) {
          if (obj !== false && obj !== nil) {
            result      = true;
            $breaker.$v = nil;

            return $breaker;
          }
        };
      }

      each.call(this);

      return result;
    }
  end

  def collect(&block)
    return enum_for :collect unless block_given?

    %x{
      var result = [], each = this.m$each;

      each.$P = function () {
        var obj = $slice.call(arguments),
            value;

        if ((value = $yield.apply($context, obj)) === $breaker) {
          return $breaker.$v;
        }

        result.push(value);
      };

      each.call(this);

      return result;
    }
  end

  def count(object = undefined, &block)
    %x{
      var result = 0, each = this.m$each;

      if (block === nil) {
        if (object === undefined) {
          $yield = function() { return true; };
        }
        else {
          $yield = function(obj) { return #{`obj` == `object`}; };
        }
      }

      each.$P = function(obj) {
        var value;

        if ((value = $yield.call($context, obj)) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          result++;
        }
      };

      each.call(this);

      return result;
    }
  end

  def detect(ifnone = undefined, &block)
    return enum_for :detect, ifnone unless block

    %x{
      var result = nil, each = this.m$each;

      each.$P = function(obj) {
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

      each.call(this);

      if (result !== nil) {
        return result;
      }

      if (typeof(ifnone) === 'function') {
        return ifnone.m$call();
      }

      return ifnone === undefined ? nil : ifnone;
    }
  end

  def drop(number)
    raise NotImplementedError

    %x{
      var result  = [],
          current = 0,
          each    = this.m$each;

      each.$P = function(obj) {
        if (number < current) {
          result.push(e);
        }

        current++;
      };

      each.call(this);

      return result;
    }
  end

  def drop_while(&block)
    return enum_for :drop_while unless block

    %x{
      var result = [];

      this.m$each(function (iter, obj) {
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
      });

      return result;
    }
  end

  def each_with_index(&block)
    return enum_for :each_with_index unless block

    %x{
      var index = 0;

      this.m$each(function (iter, obj) {
        var value;

        if ((value = $yield.call($context, obj, index)) === $breaker) {
          return $breaker.$v;
        }

        index++;
      });

      return nil;
    }
  end

  def entries
    %x{
      var result = [], each = this.m$each;

      each.$P = function(obj) { return result.push(obj); };
      each.call(this);

      return result;
    }
  end

  alias find detect

  def find_index(object = undefined, &block)
    return enum_for :find_index, object unless block

    %x{
      if (object !== undefined) {
        $yield = function (iter, obj) { return obj.m$eq$(object); };
      }

      var result = nil;

      this.m$each_with_index(function(iter, obj, index) {
        var value;

        if ((value = $yield.call($context, obj)) === $breaker) {
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

      if (number === undefined) {
        this.m$each(function (iter, obj) { result = obj; return $breaker; });
      }
      else {
        this.m$each(function (iter, obj) {
          if (number < current) {
            return $breaker;
          }

          result.push(obj);

          current++;
        });
      }

      return result;
    }
  end

  def grep(pattern, &block)
    %x{
      var result = [];

      if (block !== nil) {
        this.m$each(function (iter, obj) {
          var value = pattern.m$eqq$(obj);

          if (value !== false && value !== nil) {
            if ((value = $yield.call($context, obj)) === $breaker) {
              return $breaker.$v;
            }

            result.push(obj);
          }
        });
      }
      else {
        this.m$each(function (iter, obj) {
          var value = pattern.m$eqq$(obj);

          if (value !== false && value !== nil) {
            ary.push(obj);
          }
        });
      }

      return result;
    }
  end

  alias to_a entries
end
