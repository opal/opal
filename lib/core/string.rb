# -*- encoding: utf-8 -*-

# String objects holds a sequence of bytes, typically representing
# characters. Strings may be constructed by using methods like
# {String.new} or literals, like the following:
#
#     String.new("foo")     # => "foo"
#     "bar"                 # => "bar"
#
# Strings in Opal are immutable; which means that their contents cannot
# be changed. This means that a lot of methods like `strip!` are not
# present, and will yield a `NoMethodError`. Thier immutable
# counterparts are still available, which typically just return a new
# string.
#
# Implementation details
# ----------------------
#
# Ruby strings are toll-free bridged to native javascript strings,
# meaning that anywhere that a ruby string is required, a normal
# javascript string may be passed. This dramatically improves the
# performance of Opal due to a lower overhead in allocating strings as
# well as the ability to used functions of the String prototype to
# perform many of the core ruby methods.
#
# It is due to this limitation that strings are immutable. Javascript
# strings are immutable too, which limits what can be done with them in
# regards to Ruby methods.
#
# Ruby compatibility
# ------------------
#
# As discussed, {String} instances are immutable so they do not
# implement any of the self mutable methods found in the ruby core
# library. Most of these methods have their relative immutable
# implementations, or alternative methods to take their place.
#
# Custom subclasses of {String} can be used, and are constructed in the
# {.new} method. To due opals internals, a regular string is constructed
# using `new String(string_content)`, and its class and method table
# simply pointed at the custom subclass. As these custom subclasses are
# simply javascript strings as well, they are also limited to being
# immutable. This is because they share the same internal structre as
# regular {String} instances.
#
# String instances will never actually have their {.allocate} methods
# called. Due to the way opal bridges strings to javascript, when a new
# string is constructed, its value must be know. This is not possible in
# `allocate` as the value is not passed. Therefore the creation of
# strings (including subclasses) is done in {.new} where the string
# value is passed as an argument.
#
# Finally, strings do not currently include the `Comparable` module, as
# it is not yet implemented. The main methods used by {String} from this
# module are implemented directly as String methods. When `Comparable`
# is implemented, these methods will be moved back to the module.
class String

  def self.new(str = "")
    `var result = new String(str);
    result.$klass = self;
    result.$m = self.$m_tbl;
    return result;`
  end

  # Copy - returns a new string containing `count` copies of the receiver.
  #
  # @example
  #
  #     'Ho! ' * 3
  #     # => 'Ho! Ho! Ho! '
  #
  # @param [Numeric] count number of copies
  # @return [String]
  def *(count)
    `var result = [];

    for (var i = 0; i < count; i++) {
      result.push(self);
    }

    return result.join('');`
  end

  # Concatenation - Returns a new string containing `other` concatenated onto
  # `self`.
  #
  # @example
  #
  #     'Hello from ' + self.to_s
  #     # => 'Hello from main'
  #
  # @param [String] other string to concatenate
  # @return [String]
  def +(other)
    `return self + other;`
  end

  # Returns a copy of `self` with the first character converted to uppercase and
  # the remaining to lowercase.
  #
  # @example
  #
  #     'hello'.capitalize
  #     # => 'Hello'
  #     'HELLO'.capitalize
  #     # => 'Hello'
  #     '123ABC'.capitalize
  #     # => '123abc'
  #
  # @return [String]
  def capitalize
    `return self.charAt(0).toUpperCase() + self.substr(1).toLowerCase();`
  end

  # Returns a copy of `self` with all uppercase letters replaces with their
  # lowercase counterparts.
  #
  # @example
  #
  #     'hELLo'.downcase
  #     # => 'hello'
  #
  # @return [String]
  def downcase
    `return self.toLowerCase();`
  end

  # Returns a printable version of `self`, surrounded with quotation marks, with
  # all special characters escaped.
  #
  # @example
  #
  #     str = "hello"
  #     str.inspect
  #     # => "\"hello\""
  #
  # @return [String]
  def inspect
    `/* borrowed from json2.js, see file for license */
    var cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,

    escapable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,

    meta = {
      '\b': '\\b',
      '\t': '\\t',
      '\n': '\\n',
      '\f': '\\f',
      '\r': '\\r',
      '"' : '\\"',
      '\\': '\\\\'
    };

    escapable.lastIndex = 0;

    return escapable.test(self) ? '"' + self.replace(escapable, function (a) {
      var c = meta[a];
      return typeof c === 'string' ? c :
        '\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
      }) + '"' : '"' + self + '"';`
  end

  # Returns the number of characters in `self`.
  #
  # @return [Numeric]
  def length
    `return self.length;`
  end

  def to_i
    `return parseInt(self);`
  end

  # Returns the corresponding symbol for the receiver.
  #
  # @example
  #
  #     "koala".to_sym      # => :Koala
  #     'cat'.to_sym        # => :cat
  #     '@cat'.to_sym       # => :@cat
  #
  # This can also be used to create symbols that cannot be created using the
  # :xxxx notation.
  #
  # @return [Symbol]
  def to_sym
    `return $rb.Y(self);`
  end

  def intern
    `return $rb.Y(self);`
  end

  # Returns a new string with the characters from `self` in reverse order.
  #
  # @example
  #
  #     'stressed'.reverse
  #     # => 'desserts'
  #
  # @return [String]
  def reverse
    `return self.split('').reverse().join('');`
  end

  def succ
    `return String.fromCharCode(self.charCodeAt(0));`
  end

  def [](idx)
    `return self.substr(idx, idx + 1);`
  end

  def sub(pattern)
    `return self.replace(pattern, function(str) {
      return #{yield `str`};
    });`
  end

  def gsub(pattern, replace)
    `var r = pattern.toString();
    r = r.substr(1, r.lastIndexOf('/') - 1);
    r = new RegExp(r, 'g');
    return self.replace(pattern, function(str) {
      return replace;
    });`
  end

  def slice(start, finish = nil)
    `return self.substr(start, finish);`
  end

  def split(split, limit = nil)
    `return self.split(split);`
  end

  # Comparison - returns -1 if `other` is greater than, 0 if `other` is equal to
  # or 1 if `other` is less than `self. Returns nil if `other` is not a string.
  #
  # @example
  #
  #     'abcdef' <=> 'abcde'        # => 1
  #     'abcdef' <=> 'abcdef'       # => 0
  #     'abcdef' <=> 'abcdefg'      # => -1
  #     'abcdef' <=> 'ABCDEF'       # => 1
  #
  # @param [String] other string to compare
  # @return [-1, 0, 1, nil] result
  def <=>(other)
    `if (typeof other != 'string') return nil;
    else if (self > other) return 1;
    else if (self < other) return -1;
    return 0;`
  end

  # Equality - if other is not a string, returns false. Otherwise, returns true
  # if self <=> other returns zero.
  #
  # @param [String] other string to compare
  # @return [true, false]
  def ==(other)
    `return self.valueOf() === other.valueOf() ? Qtrue : Qfalse;`
  end

  # Match - if obj is a Regexp, then uses it to match against self, returning
  # nil if there is no match, or the index of the match location otherwise. If
  # obj is not a regexp, then it calls =~ on it, using the receiver as an
  # argument
  #
  # TODO passing a non regexp is not currently supported
  #
  # @param [Regexp, Objec] obj
  # @return [Numeric, nil]
  def =~(obj)
    `if (obj.$flags & $rb.T_STRING) {
      $rb.raise(VM.TypeError, "type mismatch: String given");
    }`

    obj =~ self
  end

  # Case-insensitive version of {#<=>}
  #
  # @example
  #
  #     'abcdef'.casecmp 'abcde'        # => 1
  #     'aBcDeF'.casecmp 'abcdef'       # => 0
  #     'abcdef'.casecmp 'aBcdEFg'      # => -1
  #
  # @param [String] other string to compare
  # @return [-1, 0, 1, nil]
  def casecmp(other)
    `if (typeof other != 'string') return nil;
    var a = self.toLowerCase(), b = other.toLowerCase();
    if (a > b) return 1;
    else if (a < b) return -1;
    return 0;`
  end

  # Returns `true` if self has a length of zero.
  #
  # @example
  #
  #     'hello'.empty?
  #     # => false
  #     ''.empty?
  #     # => true
  #
  # @return [true, false]
  def empty?
    `return self.length == 0 ? Qtrue : Qfalse;`
  end

  # Returns true is self ends with the given suffix.
  #
  # @example
  #
  #     'hello'.end_with? 'lo'
  #     # => true
  #
  # @param [String] suffix the suffix to check
  # @return [true, false]
  def end_with?(suffix)
    `if (self.lastIndexOf(suffix) == self.length - suffix.length) {
      return Qtrue;
    }

    return Qfalse;`
  end

  # Two strings are equal if they have the same length and content.
  #
  # @param [String] other string to compare
  # @return [true, false]
  def eql?(other)
    `return self == other ? Qtrue : Qfalse;`
  end

  # Returns true if self contains the given string `other`.
  #
  # @example
  #
  #     'hello'.include? 'lo'     # => true
  #     'hello'.include? 'ol'     # => false
  #
  # @param [String] other string to check for
  # @return [true, false]
  def include?(other)
    `return self.indexOf(other) == -1 ? Qfalse : Qtrue;`
  end

  # Returns the index of the first occurance of the given `substr` or pattern in
  # self. Returns `nil` if not found. If the second param is present then it
  # specifies the index of self to begin searching.
  #
  # **TODO** regexp and offsets not yet implemented.
  #
  # @example
  #
  #     'hello'.index 'e'         # => 1
  #     'hello'.index 'lo'        # => 3
  #     'hello'.index 'a'         # => nil
  #
  # @param [String] substr string to check for
  # @return [Numeric, nil]
  def index(substr)
    `var res = self.indexOf(substr);

    return res == -1 ? nil : res;`
  end

  # Returns a copy of self with leading whitespace removed.
  #
  # @example
  #
  #     '   hello   '.lstrip
  #     # => 'hello   '
  #     'hello'.lstrip
  #     # => 'hello'
  #
  # @return [String]
  def lstrip
    `return self.replace(/^\s*/, '');`
  end
end

