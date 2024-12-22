# backtick_javascript: true
# use_strict: true
# opal_runtime_mode: true
# helpers: truthy, deny_frozen_access

# rubocop:disable Layout/EmptyLineBetweenDefs

module ::Opal
  # Operator helpers
  # ----------------

  %x{
    function are_both_numbers(l,r) {
      return typeof(l) === 'number' && typeof(r) === 'number'
    }
  }

  def self.rb_plus(l = undefined, r = undefined) =
    `are_both_numbers(l,r) ? l + r : l['$+'](r)`
  def self.rb_minus(l = undefined, r = undefined) =
    `are_both_numbers(l,r) ? l - r : l['$-'](r)`
  def self.rb_times(l = undefined, r = undefined) =
    `are_both_numbers(l,r) ? l * r : l['$*'](r)`
  def self.rb_divide(l = undefined, r = undefined) =
    `are_both_numbers(l,r) ? l / r : l['$/'](r)`
  def self.rb_lt(l = undefined, r = undefined) =
    `are_both_numbers(l,r) ? l < r : l['$<'](r)`
  def self.rb_gt(l = undefined, r = undefined) =
    `are_both_numbers(l,r) ? l > r : l['$>'](r)`
  def self.rb_le(l = undefined, r = undefined) =
    `are_both_numbers(l,r) ? l <= r : l['$<='](r)`
  def self.rb_ge(l = undefined, r = undefined) =
    `are_both_numbers(l,r) ? l >= r : l['$>='](r)`

  # Optimized helpers for calls like $truthy((a)['$==='](b)) -> $eqeqeq(a, b)
  %x{
    function are_both_numbers_or_strings(lhs, rhs) {
      return (typeof lhs === 'number' && typeof rhs === 'number') ||
             (typeof lhs === 'string' && typeof rhs === 'string');
    }
  }

  def self.eqeq(lhs = undefined, rhs = undefined) =
    `are_both_numbers_or_strings(lhs,rhs) ? lhs === rhs : $truthy((lhs)['$=='](rhs))`
  def self.eqeqeq(lhs = undefined, rhs = undefined) =
    `are_both_numbers_or_strings(lhs,rhs) ? lhs === rhs : $truthy((lhs)['$==='](rhs))`
  def self.neqeq(lhs = undefined, rhs = undefined) =
    `are_both_numbers_or_strings(lhs,rhs) ? lhs !== rhs : $truthy((lhs)['$!='](rhs))`

  def self.not(arg = undefined)
    %x{
      if (undefined === arg || null === arg || false === arg || nil === arg) return true;
      if (true === arg || arg['$!'].$$pristine) return false;
      return $truthy(arg['$!']());
    }
  end

  # Shortcuts - optimized function generators for simple kinds of functions

  def self.return_self = `this`

  def self.return_ivar(ivar = undefined)
    %x{
      return function() {
        if (this[ivar] == null) { return nil; }
        return this[ivar];
      }
    }
  end

  def self.assign_ivar(ivar = undefined)
    %x{
      return function(val) {
        $deny_frozen_access(this);
        return this[ivar] = val;
      }
    }
  end

  def self.assign_ivar_val(ivar = undefined, static_val = undefined)
    %x{
      return function() {
        $deny_frozen_access(this);
        return this[ivar] = static_val;
      }
    }
  end

  # Arrays of size > 32 elements that contain only strings,
  # symbols, integers and nils are compiled as a self-extracting
  # string.
  def self.large_array_unpack(str = undefined)
    %x{
      var array = str.split(","), length = array.length, i;
      for (i = 0; i < length; i++) {
        switch(array[i][0]) {
          case undefined:
            array[i] = nil
            break;
          case '-':
          case '0':
          case '1':
          case '2':
          case '3':
          case '4':
          case '5':
          case '6':
          case '7':
          case '8':
          case '9':
            array[i] = +array[i];
        }
      }
      return array;
    }
  end
end

::Opal

# rubocop:enable Layout/EmptyLineBetweenDefs
