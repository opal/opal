module Enumerable
  def all?(&block)
    `
      var result = true, proc, val;
      if (block !== nil) {
        proc = function(iter, obj) {
          if ((val = $iterator.call($context, null, obj)) === $breaker)
            return $breaker.$v;

          if (val === false || val === nil) {
            result = false;
            $breaker.$v = nil;
            return $breaker;
          }
        }; 
      }
      else {
        proc = function(iter, obj) {
          if (obj === false || obj === nil) {
            result = false;
            $breaker.$v = nil;
            return $breaker;
          }
        };
      }

      self.m$each(proc);
      return result;
    `
  end

  def any?(&block)
    `
      var result = false, proc, val;
      if (block !== nil) {
        proc = function(iter, obj) {
          if ((val = $iterator.call($context, null, obj)) === $breaker)
            return $breaker.$v;

          if (val !== false && val !== nil) {
            result = true;
            $breaker.$v = nil;
            return $breaker;
          }
        };
      }
      else {
        proc = function(iter, obj) {
          if (obj !== false && obj !== nil) {
            result = true;
            $breaker.$v = nil;
            return $breaker;
          }
        };
      }

      self.m$each(proc);
      return result;
    `
  end

  def collect(&block)
    `
      if (block === nil) return self.m$enum_for(null, "collect");

      var result = [], val, obj;
      var proc = function() {
        obj = ArraySlice.call(arguments, 1);
        if ((val = $iterator.apply($context, [null].concat(obj))) === $breaker)
          return $breaker.$v;

        result.push(val);
      };

      self.m$each(proc);
      return result;
    `
  end

  def count(object = undefined, &block)
    `
      var result = 0, val;
      if (block !== nil)
        null;
      else if (object === undefined)
        $iterator = function() { return true; };
      else
        $iterator = function(iter, obj) { return obj.m$eq$(object); };

      var proc = function(iter, obj) {
        if ((val = $iterator.call($context, null, obj)) === $breaker)
          return $breaker.$v;

        if (val !== false && val !== nil) result++;
      };

      self.m$each(proc);
      return result;
    `
  end

  def detect(ifnone, &block)
    `
      if (block === nil) return self.m$enum_for(null, "detect");

      var result = nil, val;
      var proc = function(iter, obj) {
        if ((val = $iterator.call($context, null, obj)) === $breaker)
          return $breaker.$v;

        if (val !== false && val !== nil) {
          result = obj;
          $breaker.$v = nil;
          return $breaker;
        }
      };

      self.m$each(proc);

      if (result !== nil) return result;
      if (typeof ifnone === 'function') return ifnone.m$call(null);
      return ifnone === undefined ? nil : ifnone;
    `
  end

  def drop(number)
    `
      var result = [], current = 0;
      var proc = function(iter, obj) {
        if (number < current) result.push(e);
        current++;
      };

      return result;
    `
  end

  def drop_while(&block)
    `
      if (block === nil) return self.m$enum_for(null, "drop_while");

      var result = [], val;
      var proc = function(iter, obj) {
        if ((val = $iterator.call($context, null, obj)) === $breaker)
          return $breaker.$v;

        if (val !== false && val !== nil) result.push(obj);
        else return $breaker;
      };

      self.m$each(proc);
      return result;
    `
  end

  def each_with_index(&block)
    `
      if (block === nil) return self.m$enum_for(null, "each_with_index");

      var index = 0, val;
      var proc = function(iter, obj) {
        if ((val = $iterator.call($context, null, obj, index)) === $breaker)
          return $breaker.$v;

        index++;
      };

      self.m$each(proc);
      return nil;
    `
  end

  def entries
    `
      var result = [], proc = function(iter, obj) { return result.push(obj); };
      self.m$each(proc);
      return result;
    `
  end

  alias_method :find, :detect

  def find_index(object = undefined, &block)
    `
      if (object === undefined && block === nil) return self.m$enum_for(null, "find_index");
      if (object !== undefined) $iterator = function(iter, obj) { return obj.m$eq$(object); };

      var val, result = nil;
      self.m$each_with_index(function(iter, obj, index) {
        if ((val = $iterator.call($context, null, obj)) === $breaker)
          return $breaker.$v;

        if (val !== false && val !== nil) {
          result = obj;
          breaker.$v = index;
          return $breaker;
        }
      });

      return result;
    `
  end

  def first(number = undefined)
    `
      var result = [], current = 0;

      if (number === undefined) {
        self.m$each(function(iter, obj) { result = obj; return $breaker; });
      }
      else {
        self.m$each(function(iter, obj) {
          if (number < current) return $breaker;
          result.push(obj);
          current++;
        });
      }

      return result;
    `
  end

  def grep(pattern, &block)
    `
      var ary = [], val;

      if (block !== nil) {
        self.m$each(function(iter, obj) {
          if (val = pattern.m$eqq$(obj), val !== false && val !== nil) {
            if ((val = $iterator.call($context, null, obj)) === $breaker)
              return $breaker.$v;

            ary.push(obj);
          }
        });
      }
      else {
        self.m$each(function(iter, obj) {
          if (val = pattern.m$eqq$(obj), val !== false && val !== nil) {
            ary.push(obj);
          }
        });
      }

      return ary;
    `
  end

  alias_method :to_a, :entries
end
