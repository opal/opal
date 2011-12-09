module Enumerable
  def all?(&block)
    `
      var result = true;

      if (block !== nil) {
        self.m$each(function (iter, obj) {
          var value;

          if ((value = $yielder.call($context, null, obj)) === $breaker) {
            return $breaker.$v;
          }

          if (value === false || value === nil) {
            result      = false;
            $breaker.$v = nil;

            return $breaker;
          }
        });
      }
      else {
        self.m$each(function (iter, obj) {
          if (obj === false || obj === nil) {
            result      = false;
            $breaker.$v = nil;

            return $breaker;
          }
        });
      }

      return result;
    `
  end

  def any?(&block)
    `
      var result = false, proc;

      if (block !== nil) {
        self.m$each(function (iter, obj) {
          var value;

          if ((value = $yielder.call($context, null, obj)) === $breaker)
            return $breaker.$v;
          }

          if (value !== false && value !== nil) {
            result      = true;
            $breaker.$v = nil;

            return $breaker;
          }
        });
      }
      else {
        self.m$each(function (iter, obj) {
          if (obj !== false && obj !== nil) {
            result      = true;
            $breaker.$v = nil;

            return $breaker;
          }
        });
      }

      return result;
    `
  end

  def collect(&block)
    return enum_for :collect unless block_given?

    `
      var result = [];

      self.m$each(function () {
        var obj = ArraySlice.call(arguments, 1),
            value;

        if ((value = $yielder.apply($context, [null].concat(obj))) === $breaker) {
          return $breaker.$v;
        }

        result.push(value);
      });

      return result;
    `
  end

  def count(object = undefined, &block)
    `
      var result = 0;

      if (object === undefined) {
        $yielder = function () { return true; };
      }
      else {
        $yielder = function (iter, obj) { return obj.m$eq$(null, object); };
      }

      self.m$each(function(iter, obj) {
        var value;

        if ((value = $yielder.call($context, null, obj)) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          result++;
        }
      });

      return result;
    `
  end

  def detect(ifnone, &block)
    return enum_for :detect, ifnone unless block

    `
      var result = nil;

      self.m$each(function(iter, obj) {
        var value;

        if ((value = $yielder.call($context, null, obj)) === $breaker) {
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
        return ifnone.m$call(null);
      }

      return ifnone === undefined ? nil : ifnone;
    `
  end

  def drop(number)
    raise NotImplementedError

    `
      var result  = [],
          current = 0;

      var proc = function(iter, obj) {
        if (number < current) result.push(e);
        current++;
      };

      return result;
    `
  end

  def drop_while(&block)
    return enum_for :drop_while unless block

    `
      var result = [];

      self.m$each(function (iter, obj) {
        var value;

        if ((value = $yielder.call($context, null, obj)) === $breaker) {
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
    `
  end

  def each_with_index(&block)
    return enum_for :each_with_index unless block

    `
      var index = 0;

      self.m$each(function (iter, obj) {
        var value;

        if ((value = $yielder.call($context, null, obj, index)) === $breaker) {
          return $breaker.$v;
        }

        index++;
      });

      return nil;
    `
  end

  def entries
    `
      var result = [];

      self.m$each(function (iter, obj) { return result.push(obj); })

      return result;
    `
  end

  alias_method :find, :detect

  def find_index(object = undefined, &block)
    return enum_for :find_index, object unless block

    `
      if (object !== undefined) {
        $yielder = function (iter, obj) { return obj.m$eq$(object); };
      }

      var result = nil;

      self.m$each_with_index(function(iter, obj, index) {
        var value;

        if ((value = $yielder.call($context, null, obj)) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          result     = obj;
          breaker.$v = index;

          return $breaker;
        }
      });

      return result;
    `
  end

  def first(number = undefined)
    `
      var result = [],
          current = 0;

      if (number === undefined) {
        self.m$each(function (iter, obj) { result = obj; return $breaker; });
      }
      else {
        self.m$each(function (iter, obj) {
          if (number < current) {
            return $breaker;
          }

          result.push(obj);

          current++;
        });
      }

      return result;
    `
  end

  def grep(pattern, &block)
    `
      var result = [];

      if (block !== nil) {
        self.m$each(function (iter, obj) {
          var value = pattern.m$eqq$(obj);

          if (value !== false && value !== nil) {
            if ((value = $yielder.call($context, null, obj)) === $breaker) {
              return $breaker.$v;
            }

            result.push(obj);
          }
        });
      }
      else {
        self.m$each(function (iter, obj) {
          var value = pattern.m$eqq$(obj);

          if (value !== false && value !== nil) {
            ary.push(obj);
          }
        });
      }

      return result;
    `
  end

  alias_method :to_a, :entries
end
