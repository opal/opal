# backtick_javascript: true
# use_strict: true
# opal_runtime_mode: true
# helpers: raise

module ::Opal
  # Helpers for implementing multiple assignment
  # Our code for extracting the values and assigning them only works if the
  # return value is a JS array.
  # So if we get an Array subclass, extract the wrapped JS array from it

  # Used for: a, b = something (no splat)
  def self.to_ary(value)
    %x{
      if (value.$$is_array) {
        return value;
      }
      else if (value['$respond_to?']('to_ary', true)) {
        var ary = value.$to_ary();
        if (ary === nil) {
          return [value];
        }
        else if (ary.$$is_array) {
          return ary;
        }
        else {
          $raise(Opal.TypeError, "Can't convert " + value.$$class +
            " to Array (" + value.$$class + "#to_ary gives " + ary.$$class + ")");
        }
      }
      else {
        return [value];
      }
    }
  end

  # Used for: a, b = *something (with splat)
  def self.to_a(value)
    %x{
      if (value.$$is_array) {
        // A splatted array must be copied
        return value.slice();
      }
      else if (value['$respond_to?']('to_a', true)) {
        var ary = value.$to_a();
        if (ary === nil) {
          return [value];
        }
        else if (ary.$$is_array) {
          return ary;
        }
        else {
          $raise(Opal.TypeError, "Can't convert " + value.$$class +
            " to Array (" + value.$$class + "#to_a gives " + ary.$$class + ")");
        }
      }
      else {
        return [value];
      }
    }
  end
end

::Opal
