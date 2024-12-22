# backtick_javascript: true
# use_strict: true
# opal_runtime_mode: true
# helpers: raise, gvars

module ::Opal
  # keeps track of exceptions for $!
  `Opal.exceptions = []`

  # @private
  # Pops an exception from the stack and updates `$!`.
  def self.pop_exception(rescued_exception = undefined)
    %x{
      var exception = Opal.exceptions.pop();
      if (exception === rescued_exception) {
        // Current $! is raised in the rescue block, so we don't update it
      }
      else if (exception) {
        $gvars["!"] = exception;
      }
      else {
        $gvars["!"] = nil;
      }
    }
  end

  def self.type_error(object = undefined, type = undefined, method = undefined, coerced = undefined)
    %x{
      object = object.$$class;

      if (coerced && method) {
        coerced = coerced.$$class;
        $raise(Opal.TypeError,
          "can't convert " + object + " into " + type +
          " (" + object + "#" + method + " gives " + coerced + ")"
        )
      } else {
        $raise(Opal.TypeError,
          "no implicit conversion of " + object + " into " + type
        )
      }
    }
  end

  `TypeError.$$super = Error`

  # Finds the corresponding exception match in candidates.  Each candidate can
  # be a value, or an array of values.  Returns null if not found.
  def self.rescue(exception = undefined, candidates = undefined)
    %x{
      for (var i = 0; i < candidates.length; i++) {
        var candidate = candidates[i];

        if (candidate.$$is_array) {
          var result = Opal.rescue(exception, candidate);

          if (result) {
            return result;
          }
        }
        else if ((Opal.Opal.Raw && candidate === Opal.Opal.Raw.Error) || candidate['$==='](exception)) {
          return candidate;
        }
      }

      return null;
    }
  end

  # Define a "$@" global variable, which would compute and return a backtrace on demand.
  %x{
    Object.defineProperty($gvars, "@", {
      enumerable: true,
      configurable: true,
      get: function() {
        if ($truthy($gvars["!"])) return $gvars["!"].$backtrace();
        return nil;
      },
      set: function(bt) {
        if ($truthy($gvars["!"]))
          $gvars["!"].$set_backtrace(bt);
        else
          $raise(Opal.ArgumentError, "$! not set");
      }
    });
  }

  # Closures
  # --------

  def self.thrower(type = undefined)
    %x{
      var thrower = {
        $thrower_type: type,
        $throw: function(value, called_from_lambda) {
          if (value == null) value = nil;
          if (this.is_orphan && !called_from_lambda) {
            $raise(Opal.LocalJumpError, 'unexpected ' + type, value, type.$to_sym());
          }
          this.$v = value;
          throw this;
        },
        is_orphan: false
      }
      return thrower;
    }
  end

  `Opal.t_eval_return = Opal.thrower("return")`
end

::Opal
