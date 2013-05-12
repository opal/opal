class Regexp < `RegExp`
  def self.escape(string)
    `string.replace(/[\\-\\[\\]\\/\\{\\}\\(\\)\\*\\+\\?\\.\\\\\^\\$\\|]/g, '\\\\$&')`
  end

  def self.new(regexp, options = undefined)
    `new RegExp(regexp, options)`
  end

  def ==(other)
    `other.constructor == RegExp && #{self}.toString() === other.toString()`
  end

  alias_native :===, :test

  def =~(string)
    %x{
      var result = #{self}.exec(string);

      if (result) {
        result.$to_s    = match_to_s;
        result.$inspect = match_inspect;
        result._klass = #{MatchData};

        #{$~ = `result`};
      }
      else {
        #{$~ = nil};
      }

      return result ? result.index : nil;
    }
  end

  alias eql? ==

  alias_native :inspect, :toString

  def match(string, pos = undefined)
    %x{
      var re = #{self};
      if (!#{self}.global) {
        re = new RegExp(re.source, 'g' + (#{self}.multiline ? 'm' : '') + (#{self}.ignoreCase ? 'i' : ''));
      }

      var result  = re.exec(string);

      if (result) {
        result._klass = #{MatchData};
        result.$begin = match_begin;
        result.$captures = match_captures;
        result.$inspect = match_inspect;
        result._post_match = #{$' = `string.substr(re.lastIndex)`};
        result.$post_match = match_post_match;
        result._pre_match = #{$` = `string.substr(0, re.lastIndex - result[0].length)`};
        result.$pre_match = match_pre_match;
        result._regexp = #{self};
        result.$regexp = match_regexp;
        result.$string = match_string;
        result.$to_a = match_to_a;
        result.$to_s = match_to_s;
        result.$values_at = match_values_at;

        return #{$~ = `result`};
      }
      else {
        return #{$~ = $` = $' = nil};
      }
    }
  end

  def to_s
    `#{self}.source`
  end

  %x{
    function match_begin(pos) {
      if (pos == 0 || pos == 1) {
        return this.index;
      }
      else {
        #{raise ArgumentError, 'MatchData#begin only supports 0th element'};
      }
    }

    function match_captures() {
      return this.slice(1);
    }

    function match_inspect() {
      return "<#MatchData " + this[0].$inspect() + ">";
    }

    function match_post_match() {
      return this._post_match;
    }

    function match_pre_match() {
      return this._pre_match;
    }

    function match_regexp() {
      return this._regexp;
    }

    function match_string() {
      return this.input
    }

    function match_to_a() {
      return this.slice(0);
    }

    function match_to_s() {
      return this[0];
    }

    function match_values_at() {
      var vals = [];
      var match_length = this.length;
      for (var i = 0, length = arguments.length; i < length; i++) {
        var pos = arguments[i];
        if (pos >= 0) {
          vals.push(this[pos]);
        }
        else {
          pos = match_length + pos;
          if (pos > 0) {
            vals.push(this[pos]);
          }
          else {
            vals.push(#{nil});
          }
        }
      }

      return vals;
    }
  }
end

class MatchData
end
