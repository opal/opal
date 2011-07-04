# A `Regexp` holds a regular expression, that can be used to match
# against strings. Regexps may be created as literals, or using the
# {Regexp.new} method:
#
#     /abc/                 # => /abc/
#     Regexp.new '[a-z]'    # => /[a-z]/
#
# Implementation details
# ----------------------
#
# Instances of {Regexp} are toll-free bridged to native javascript
# regular expressions. This means that javascript regexp instances may
# be passed directly into ruby methods that expect a regexp instance.
#
# Due to the limitations of some browser engines, regexps from ruby are
# not always compatible with the target browser javascript engine.
# Compatibility differences change between engines, so reading up on a
# particular browsers documentation might point to differences
# discovered. The majority of regexp syntax is typically the same.
class Regexp

  def self.escape(s)
    s
  end

  def self.new(s)
    `return $rb.re(new RegExp(s));`
  end

  def inspect
    `return self.$re.toString();`
  end

  def to_s
    `return self.$re.source;`
  end

  def ==(other)
    `return self.toString() === other.toString() ? Qtrue : Qfalse;`
  end

  def eql?(other)
    self == other
  end

  # Match - matches the regular expression against the given string. If
  # the string matches, the index of the match is returned. Otherwise,
  # `nil` is returned to imply no match.
  #
  # @param [String] str The string to match
  # @return [Numeric, nil]
  def =~(str)
    `var result = self.$re.exec(str);
    $rb.X = result;

    if (result) {
      return result.index;
    }
    else {
      return nil;
    }`
  end

  def match(pattern)
    self =~ pattern
    $~
  end
end

