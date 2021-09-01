##
# == Manipulates strings like the UNIX Bourne shell
#
# This module manipulates strings according to the word parsing rules
# of the UNIX Bourne shell.
#
# The shellwords() function was originally a port of shellwords.pl,
# but modified to conform to POSIX / SUSv3 (IEEE Std 1003.1-2001 [1]).
#
# === Usage
#
# You can use Shellwords to parse a string into a Bourne shell friendly Array.
#
#   require 'shellwords'
#
#   argv = Shellwords.split('three blind "mice"')
#   argv #=> ["three", "blind", "mice"]
#
# Once you've required Shellwords, you can use the #split alias
# String#shellsplit.
#
#   argv = "see how they run".shellsplit
#   argv #=> ["see", "how", "they", "run"]
#
# Be careful you don't leave a quote unmatched.
#
#   argv = "they all ran after the farmer's wife".shellsplit
#        #=> ArgumentError: Unmatched double quote: ...
#
# In this case, you might want to use Shellwords.escape, or its alias
# String#shellescape.
#
# This method will escape the String for you to safely use with a Bourne shell.
#
#   argv = Shellwords.escape("special's.txt")
#   argv #=> "special\\'s.txt"
#   system("cat " + argv)
#
# Shellwords also comes with a core extension for Array, Array#shelljoin.
#
#   argv = %w{ls -lta lib}
#   system(argv.shelljoin)
#
# You can use this method to create an escaped string out of an array of tokens
# separated by a space. In this example we used the literal shortcut for
# Array.new.
#
# === Authors
# * Wakou Aoyama
# * Akinori MUSHA <knu@iDaemons.org>
#
# === Contact
# * Akinori MUSHA <knu@iDaemons.org> (current maintainer)
#
# === Resources
#
# 1: {IEEE Std 1003.1-2004}[http://pubs.opengroup.org/onlinepubs/009695399/toc.htm]

module Shellwords
  # LICENSE FROM: https://github.com/substack/node-shell-quote/tree/1.4.3
  #
  #   The MIT License
  #
  #   Copyright (c) 2013 James Halliday (mail@substack.net)
  #
  #   Permission is hereby granted, free of charge,
  #   to any person obtaining a copy of this software and
  #   associated documentation files (the "Software"), to
  #   deal in the Software without restriction, including
  #   without limitation the rights to use, copy, modify,
  #   merge, publish, distribute, sublicense, and/or sell
  #   copies of the Software, and to permit persons to whom
  #   the Software is furnished to do so,
  #   subject to the following conditions:
  #
  #   The above copyright notice and this permission notice
  #   shall be included in all copies or substantial portions of the Software.
  #
  #   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  #   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
  #   OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
  #   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
  #   ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
  #   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
  #   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  #
  Native = `{}`
  %x(
    (function(exports) {
      var json = JSON;
      var hasOwn = Object.prototype.hasOwnProperty;

      // https://github.com/substack/array-map/blob/master/LICENSE
      var map = function (xs, f) {
          if (xs.map) return xs.map(f);
          var res = [];
          for (var i = 0; i < xs.length; i++) {
              var x = xs[i];
              if (hasOwn.call(xs, i)) res.push(f(x, i, xs));
          }
          return res;
      };

      // https://github.com/juliangruber/array-filter#license
      var filter = function (arr, fn, self) {
        if (arr.filter) return arr.filter(fn, self);
        if (void 0 === arr || null === arr) throw new TypeError;
        if ('function' != typeof fn) throw new TypeError;
        var ret = [];
        for (var i = 0; i < arr.length; i++) {
          if (!hasOwn.call(arr, i)) continue;
          var val = arr[i];
          if (fn.call(self, val, i, arr)) ret.push(val);
        }
        return ret;
      };

      // https://github.com/substack/array-reduce/blob/master/LICENSE
      var reduce = function (xs, f, acc) {
          var hasAcc = arguments.length >= 3;
          if (hasAcc && xs.reduce) return xs.reduce(f, acc);
          if (xs.reduce) return xs.reduce(f);

          for (var i = 0; i < xs.length; i++) {
              if (!hasOwn.call(xs, i)) continue;
              if (!hasAcc) {
                  acc = xs[i];
                  hasAcc = true;
                  continue;
              }
              acc = f(acc, xs[i], i);
          }
          return acc;
      };

      exports.quote = function (xs) {
          return map(xs, function (s) {
              if (s && typeof s === 'object') {
                  return s.op.replace(/(.)/g, '\\$1');
              }
              else if (/["\s]/.test(s) && !/'/.test(s)) {
                  return "'" + s.replace(/(['\\])/g, '\\$1') + "'";
              }
              else if (/["'\s]/.test(s)) {
                  return '"' + s.replace(/(["\\$`!])/g, '\\$1') + '"';
              }
              else {
                  return String(s).replace(/([\\$`()!#&*|])/g, '\\$1');
              }
          }).join(' ');
      };

      var CONTROL = '(?:' + [
          '\\|\\|', '\\&\\&', ';;', '\\|\\&', '[&;()|<>]'
      ].join('|') + ')';
      var META = '|&;()<> \\t';
      var BAREWORD = '(\\\\[\'"' + META + ']|[^\\s\'"' + META + '])+';
      var DOUBLE_QUOTE = '"((\\\\"|[^"])*?)"';
      var SINGLE_QUOTE = '\'((\\\\\'|[^\'])*?)\'';
      var UNMATCHED_DOUBLE_QUOTE = '"((\\\\"|[^"])*?)';
      var UNMATCHED_SINGLE_QUOTE = '\'((\\\\\'|[^\'])*?)';
      var UnmatchedQuoteError = {};

      var TOKEN = '';
      for (var i = 0; i < 4; i++) {
          TOKEN += (Math.pow(16,8)*Math.random()).toString(16);
      }

      exports.parse = function (line, env) {
          return parse(line, env, line);
      };

      function parse (s, env, full_line) {
          var chunker = new RegExp([
              '(' + CONTROL + ')', // control chars
              '(' + [
                  BAREWORD,
                  SINGLE_QUOTE,
                  DOUBLE_QUOTE,
                  UNMATCHED_SINGLE_QUOTE,
                  UNMATCHED_DOUBLE_QUOTE
                ].join('|') + ')*'
          ].join('|'), 'g');
          var match = filter(s.match(chunker), Boolean);
          if (!match) return [];
          if (!env) env = {};
          return map(match, function (s) {
              if (RegExp('^' + CONTROL + '$').test(s)) {
                  // return { op: s };
                  return s;
              }

              // Hand-written scanner/parser for Bash quoting rules:
              //
              //  1. inside single quotes, all characters are printed literally.
              //  2. inside double quotes, all characters are printed literally
              //     except variables prefixed by '$' and backslashes followed by
              //     either a double quote or another backslash.
              //  3. outside of any quotes, backslashes are treated as escape
              //     characters and not printed (unless they are themselves escaped)
              //  4. quote context can switch mid-token if there is no whitespace
              //     between the two quote contexts (e.g. all'one'"token" parses as
              //     "allonetoken")
              var SQ = "'";
              var DQ = '"';
              var BS = '\\';
              var DS = '$';
              var quote = false;
              var varname = false;
              var esc = false;
              var out = '';
              var isGlob = false;

              for (var i = 0, len = s.length; i < len; i++) {
                  var c = s.charAt(i);
                  isGlob = isGlob || (!quote && (c === '*' || c === '?'))
                  if (esc) {
                      out += c;
                      esc = false;
                  }
                  else if (quote) {
                      if (c === quote) {
                          quote = false;
                      }
                      else if (quote == SQ) {
                          out += c;
                      }
                      else { // Double quote
                          if (c === BS) {
                              i += 1;
                              c = s.charAt(i);
                              if (c === DQ || c === BS || c === DS) {
                                  out += c;
                              } else {
                                  out += BS + c;
                              }
                          }
                          else if (c === DS) {
                              out += parseEnvVar();
                          }
                          else {
                              out += c
                          }
                      }
                  }
                  else if (c === DQ || c === SQ) {
                      quote = c;
                  }
                  else if (RegExp('^' + CONTROL + '$').test(c)) {
                      // return { op: s };
                      out += s
                  }
                  else if (c === BS) {
                      esc = true
                  }
                  else if (c === DS) {
                      out += parseEnvVar();
                  }
                  else out += c;
              }

              // if (isGlob) return {op: 'glob', pattern: out};

              if (quote) {
                #{raise ArgumentError, "Unmatched quote: #{`full_line`.inspect}"}
              }

              return out;

              function parseEnvVar() {
                  i += 1;
                  var varend, varname;
                  //debugger
                  if (s.charAt(i) === '{') {
                      i += 1
                      if (s.charAt(i) === '}') {
                          throw new Error("Bad substitution: " + s.substr(i - 2, 3));
                      }
                      varend = s.indexOf('}', i);
                      if (varend < 0) {
                          throw new Error("Bad substitution: " + s.substr(i));
                      }
                      varname = s.substr(i, varend - i);
                      i = varend;
                  }
                  else if (/[*@#?$!_\-]/.test(s.charAt(i))) {
                      varname = s.charAt(i);
                      i += 1;
                  }
                  else {
                      varend = s.substr(i).match(/[^\w\d_]/);
                      if (!varend) {
                          varname = s.substr(i);
                          i = s.length;
                      } else {
                          varname = s.substr(i, varend.index)
                          i += varend.index - 1;
                      }
                  }
                  return getVar(null, '', varname);
              }
          });

          function getVar (_, pre, key) {
              var r = typeof env === 'function' ? env(key) : env[key];
              if (r === undefined) r = '';

              if (typeof r === 'object') {
                  return pre + TOKEN + json.stringify(r) + TOKEN;
              }
              else return pre + r;
          }
      };
    })(#{Native});
  )






  # Splits a string into an array of tokens in the same way the UNIX
  # Bourne shell does.
  #
  #   argv = Shellwords.split('here are "two words"')
  #   argv #=> ["here", "are", "two words"]
  #
  # String#shellsplit is a shortcut for this function.
  #
  #   argv = 'here are "two words"'.shellsplit
  #   argv #=> ["here", "are", "two words"]
  def shellsplit(line)
    `#{Shellwords::Native}.parse(line)`
  end

  alias shellwords shellsplit

  module_function :shellsplit, :shellwords

  class << self
    alias split shellsplit
  end

  # Escapes a string so that it can be safely used in a Bourne shell
  # command line.  +str+ can be a non-string object that responds to
  # +to_s+.
  #
  # Note that a resulted string should be used unquoted and is not
  # intended for use in double quotes nor in single quotes.
  #
  #   argv = Shellwords.escape("It's better to give than to receive")
  #   argv #=> "It\\'s\\ better\\ to\\ give\\ than\\ to\\ receive"
  #
  # String#shellescape is a shorthand for this function.
  #
  #   argv = "It's better to give than to receive".shellescape
  #   argv #=> "It\\'s\\ better\\ to\\ give\\ than\\ to\\ receive"
  #
  #   # Search files in lib for method definitions
  #   pattern = "^[ \t]*def "
  #   open("| grep -Ern #{pattern.shellescape} lib") { |grep|
  #     grep.each_line { |line|
  #       file, lineno, matched_line = line.split(':', 3)
  #       # ...
  #     }
  #   }
  #
  # It is the caller's responsibility to encode the string in the right
  # encoding for the shell environment where this string is used.
  #
  # Multibyte characters are treated as multibyte characters, not as bytes.
  #
  # Returns an empty quoted String if +str+ has a length of zero.
  def shellescape(str)
    str = str.to_s

    # An empty argument will be skipped, so return empty quotes.
    return "''" if str.empty?

    # Treat multibyte characters as is.  It is the caller's responsibility
    # to encode the string in the right encoding for the shell
    # environment.
    str.gsub(/([^A-Za-z0-9_\-.,:\/@\n])/, "\\\\\\1")

    # A LF cannot be escaped with a backslash because a backslash + LF
    # combo is regarded as a line continuation and simply ignored.
    str.gsub(/\n/, "'\n'")

    return str
  end

  module_function :shellescape

  class << self
    alias escape shellescape
  end

  # Builds a command line string from an argument list, +array+.
  #
  # All elements are joined into a single string with fields separated by a
  # space, where each element is escaped for the Bourne shell and stringified
  # using +to_s+.
  #
  #   ary = ["There's", "a", "time", "and", "place", "for", "everything"]
  #   argv = Shellwords.join(ary)
  #   argv #=> "There\\'s a time and place for everything"
  #
  # Array#shelljoin is a shortcut for this function.
  #
  #   ary = ["Don't", "rock", "the", "boat"]
  #   argv = ary.shelljoin
  #   argv #=> "Don\\'t rock the boat"
  #
  # You can also mix non-string objects in the elements as allowed in Array#join.
  #
  #   output = `#{['ps', '-p', $$].shelljoin}`
  #
  def shelljoin(array)
    array.map { |arg| shellescape(arg) }.join(' ')
  end

  module_function :shelljoin

  class << self
    alias join shelljoin
  end
end

class String
  # call-seq:
  #   str.shellsplit => array
  #
  # Splits +str+ into an array of tokens in the same way the UNIX
  # Bourne shell does.
  #
  # See Shellwords.shellsplit for details.
  def shellsplit
    Shellwords.split(self)
  end

  # call-seq:
  #   str.shellescape => string
  #
  # Escapes +str+ so that it can be safely used in a Bourne shell
  # command line.
  #
  # See Shellwords.shellescape for details.
  def shellescape
    Shellwords.escape(self)
  end
end

class Array
  # call-seq:
  #   array.shelljoin => string
  #
  # Builds a command line string from an argument list +array+ joining
  # all elements escaped for the Bourne shell and separated by a space.
  #
  # See Shellwords.shelljoin for details.
  def shelljoin
    Shellwords.join(self)
  end
end
