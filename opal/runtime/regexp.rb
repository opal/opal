# backtick_javascript: true
# use_strict: true
# opal_runtime_mode: true

module ::Opal
  # Escape Regexp special chars letting the resulting string be used to build
  # a new Regexp.
  def self.escape_regexp(str = undefined)
    `Opal.escape_metacharacters(str.replace(/([-[\]\/{}()*+?.^$\\| ])/g, '\\$1'))`
  end

  def self.escape_metacharacters(str = undefined)
    %x{
      return str.replace(/[\n]/g, '\\n')
                .replace(/[\r]/g, '\\r')
                .replace(/[\f]/g, '\\f')
                .replace(/[\t]/g, '\\t');
    }
  end

  # Create a global Regexp from a RegExp object and cache the result
  # on the object itself ($$g attribute).
  def self.global_regexp(pattern = undefined)
    %x{
      if (pattern.global) {
        return pattern; // RegExp already has the global flag
      }
      if (pattern.$$g == null) {
        pattern.$$g = new RegExp(pattern.source, 'g' + pattern.flags);
      } else {
        pattern.$$g.lastIndex = null; // reset lastIndex property
      }
      return pattern.$$g;
    }
  end

  # Transform a regular expression from Ruby syntax to JS syntax.
  def self.transform_regexp(regexp = undefined, flags = undefined)
    Opal::RegexpTranspiler.transform_regexp(regexp, flags)
  end

  # Combine multiple regexp parts together
  def self.regexp(parts = undefined, flags = undefined)
    %x{
      var part;

      if (flags == null) flags = '';

      var ignoreCase = flags.includes('i');

      for (var i = 0, ii = parts.length; i < ii; i++) {
        part = parts[i];
        if (part instanceof RegExp) {
          if (part.ignoreCase !== ignoreCase)
            Opal.Kernel.$warn(
              "ignore case doesn't match for " + part.source.$inspect(),
              new Map([['uplevel',  1]])
            )

          part = part.$$source != null ? part.$$source : part.source;
        }
        if (part == '') part = '(?:)';
        parts[i] = part;
      }

      parts = parts.join('');
      parts = Opal.escape_metacharacters(parts);

      var output = Opal.transform_regexp(parts, flags);

      var regexp = new RegExp(output[0], output[1]);
      if (parts != output[0]) regexp.$$source = parts
      if (flags != output[1]) regexp.$$options = flags;
      return regexp;
    }
  end

  # Regexp has been transformed, so let's annotate the original regexp
  def self.annotate_regexp(regexp = undefined, source = undefined, options = undefined)
    %x{
      regexp.$$source = source;
      regexp.$$options = options;
      return regexp;
    }
  end

  # Annotated empty regexp
  def self.empty_regexp(flags = undefined)
    `Opal.annotate_regexp(new RegExp(/(?:)/, flags), '')`
  end
end

::Opal
