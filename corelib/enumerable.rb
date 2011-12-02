module Enumerable
  def all?(&block)
    `
      var result = true, func, proc;

      if (block === nil) {
        proc = function(e) {
          if (e === false || e === nil) {
            result = false;
            $breaker.$v = nil;
            return $breaker;
          }
        };
      }
      else {
        proc = function(e) {
          var val;

          if ((val = $iterator.call($context, e)) === $breaker) {
            return $breaker.$v;
          }

          if (val === false || val === nil) {
            result = false;
            $breaker.$v = nil;
            return $breaker;
          }
        };
      }

      func = self.m$each;
      func.proc = proc;
      func.call(self);

      return result;
    `
  end

  def any?(&block)
    `
      var result = false, func, proc;

      if (block === nil) {
        proc = function(e) {
          if (e !== false && e !== nil) {
            result = true;
            $breaker.$v = nil;
            return $breaker;
          }
        };
      }
      else {
        proc = function(e) {
          var val;

          if ((val = $iterator.call($context, e)) === $breaker) {
            return $breaker.$v;
          }

          if (val !== false && val !== nil) {
            result = true;
            $breaker.$v = nil;
            return $breaker;
          }
        }
      }

      func = self.m$each;
      func.proc = proc;
      func.call(self);

      return result;
    `
  end

  def chunk(*)
    raise NotImplementedError, 'Enumerable#chunk not yet implemented'
  end

  def collect(&block)
    `
      if (block === nil) {
        return self.m$enum_for("collect");
      }

      var result = [], val;

      var proc = function(e) {
        e = ArraySlice.call(arguments);

        if ((val = $iterator.apply($context, e)) === $breaker) {
          return $breaker.$v;
        }

        result.push(val);
      };

      var func = self.m$each;
      func.proc = proc;
      func.call(self);

      return result;
    `
  end

  def collect_concat(*)
    raise NotImplementedError, 'Enumerable#collect_concat not yet implemented'
  end

  def count(object = undefined, &block)
    result = 0

    if `(object === undefined)`
      block = block || proc { true }
    elsif !block
      block = proc { |obj| obj == object }
    end

    each {|obj|
      result += 1 if block.call(obj)
    }

    result
  end

  def cycle
    raise NotImplementedError, 'Enumerable#cycle not yet implemented'
  end

  def detect(if_none = nil)
    return enum_for :detect, if_none unless block_given?

    result = nil
    each {|obj|
      if yield obj
        result = obj
        break
      end
    }

    return result if result
    return if_none.call if Proc === if_none
    if_none
  end

  def drop (number)
    result  = []
    current = 0

    each {|obj|
      result.push(obj) if number < current
      current += 1
    }

    result
  end

  def drop_while
    return enum_for :drop_while unless block_given?

    result = []
    add    = false

    each {|obj|
      add = true if !add && !yield(obj)

      result.push(obj) if add
    }

    result
  end

  def each_cons(*)
    raise NotImplementedError, 'Enumerable#each_cons not yet implemented'
  end

  def each_entry(*)
    raise NotImplementedError, 'Enumerable#each_entry not yet implemented'
  end

  def each_slice(*)
    raise NotImplementedError, 'Enumerable#each_slice not yet implemented'
  end

  def each_with_index(*args)
    return enum_for :each_with_index, *args unless block_given?

    index = 0

    each(*args) {|obj|
      yield obj, index

      index += 1
    }
  end

  def each_with_object(object)
    return enum_for :each_with_object, obj unless block_given?

    each {|*args|
      # yield *args, object
      yiled *args
    }

    object
  end

  def entries
    `
      var result = [];

      var proc = function(e) {
        return result.push(e);
      };

      var func = self.m$each;
      func.proc = proc;
      func.call(self);

      return result;
    `
  end

  alias_method :find, :detect

  def find_all(*)
    raise NotImplementedError, 'Enumerable#find_all not yet implemented'
  end

  def find_index(object = undefined, &block)
    return enum_for :find_index unless block || `object !== undefined`

    if `object !== undefined`
      block = proc { |obj| obj == object }
    end

    each_with_index {|obj, index|
      return index if block.call(obj)
    }

    nil
  end

  def first(number = nil)
    result = []

    if number
      current = 0

      each {|obj|
        break if number < current

        result.push(obj)

        current += 1
      }
    else
      each {|obj|
        result = obj

        break
      }
    end

    result
  end

  alias_method :flat_map, :collect_concat

  def grep(pattern)
    result = []

    each {|obj|
      result.push obj if pattern === obj && (!block_given? || yield(obj))
    }

    result
  end

  def group_by
    return enum_for :group_by unless block_given?

    result = {}

    each {|obj|
      result[yield obj] = obj
    }

    result
  end

  def include?(object)
    any? {|obj|
      obj == object
    }
  end

  def inject(*)
    raise NotImplementedError, 'Enumerable#inject not yet implemented'
  end

  alias_method :map, :collect

  def max(*)
    raise NotImplementedError, 'Enumerable#max not yet implemented'
  end

  def max_by(*)
    raise NotImplementedError, 'Enumerable#max_by not yet implemented'
  end

  alias_method :member?, :include?

  def min(*)
    raise NotImplementedError, 'Enumerable#min not yet implemented'
  end

  def min_by(*)
    raise NotImplementedError, 'Enumerable#min_by not yet implemented'
  end

  def minmax(*)
    raise NotImplementedError, 'Enumerable#minmax not yet implemented'
  end

  def minmax_by(*)
    raise NotImplementedError, 'Enumerable#minmax_by not yet implemented'
  end

  def none?(*)
    raise NotImplementedError, 'Enumerable#none? not yet implemented'
  end

  def one?(*)
    raise NotImplementedError, 'Enumerable#one? not yet implemented'
  end

  def partition(*)
    raise NotImplementedError, 'Enumerable#partition not yet implemented'
  end

  alias_method :reduce, :inject

  def reject(*)
    raise NotImplementedError, 'Enumerable#reject not yet implemented'
  end

  def reverse_each(*)
    raise NotImplementedError, 'Enumerable#reverse_each not yet implemented'
  end

  alias_method :select, :find_all

  def slice_before(*)
    raise NotImplementedError, 'Enumerable#slice_before not yet implemented'
  end

  def sort(*)
    raise NotImplementedError, 'Enumerable#sort not yet implemented'
  end

  def sort_by(*)
    raise NotImplementedError, 'Enumerable#sort_by not yet implemented'
  end

  def take(*)
    raise NotImplementedError, 'Enumerable#take not yet implemented'
  end

  def take_while(*)
    raise NotImplementedError, 'Enumerable#take_while not yet implemented'
  end

  alias_method :to_a, :entries

  def zip(*)
    raise NotImplementedError, 'Enumerable# not yet implemented'
  end
end
