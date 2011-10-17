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
  def self.escape (string)
    `string.replace(/([.*+?^=!:${}()|[\]\\/\\])/g, '\\$1')`
  end

  def self.new (string, options = `undefined`)
    `new RegExp(string, options)`
  end

  def inspect
    `self.toString()`
  end

  def to_s
    `self.source`
  end

  def ==(other)
    `other.constructor == RegExp && self.toString() === other.toString()`
  end

  def ===(obj)
    `self.test(obj)`
  end

  alias_method :eql?, :==

  # Match - matches the regular expression against the given string. If
  # the string matches, the index of the match is returned. Otherwise,
  # `nil` is returned to imply no match.
  #
  # @param [String] str The string to match
  # @return [Numeric, nil]
  def =~ (string)
    `
      var result = self.exec(string);
      VM.X      = result;

      return result ? result.index : nil;
    `
  end

  def match (pattern)
    self =~ pattern

    $~
  end
end

