# backtick_javascript: true
# use_strict: true
# opal_runtime_mode: true

module ::Opal
  # Create a new range instance with first and last values, and whether the
  # range excludes the last value.
  def self.range(first = undefined, last = undefined, exc = undefined)
    %x{
      var range         = new Opal.Range();
          range.begin   = first;
          range.end     = last;
          range.excl    = exc;

      return range;
    }
  end
end

::Opal
