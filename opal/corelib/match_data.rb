class MatchData
  attr_reader :post_match, :pre_match, :regexp, :string

  def initialize(regexp, match_groups)
    $~          = self
    @regexp     = regexp
    @begin      = `match_groups.index`
    @string     = `match_groups.input`
    @pre_match  = `#@string.substr(0, regexp.lastIndex - match_groups[0].length)`
    @post_match = `#@string.substr(regexp.lastIndex)`
    @matches    = []

    %x{
      for (var i = 0, length = match_groups.length; i < length; i++) {
        var group = match_groups[i];

        if (group == null) {
          #@matches.push(nil);
        }
        else {
          #@matches.push(group);
        }
      }
    }
  end

  def [](*args)
    @matches[*args]
  end

  def ==(other)
    return false unless MatchData === other

    `self.string == other.string` &&
    `self.regexp == other.regexp` &&
    `self.pre_match == other.pre_match` &&
    `self.post_match == other.post_match` &&
    `self.begin == other.begin`
  end

  def begin(pos)
    if pos != 0 && pos != 1
      raise ArgumentError, 'MatchData#begin only supports 0th element'
    end

    @begin
  end

  def captures
    `#@matches.slice(1)`
  end

  def inspect
    %x{
      var str = "#<MatchData " + #{`#@matches[0]`.inspect};

      for (var i = 1, length = #@matches.length; i < length; i++) {
        str += " " + i + ":" + #{`#@matches[i]`.inspect};
      }

      return str + ">";
    }
  end

  def length
    `#@matches.length`
  end

  alias size length

  def to_a
    @matches
  end

  def to_s
    `#@matches[0]`
  end

  def values_at(*indexes)
    %x{
      var values       = [],
          match_length = #@matches.length;

      for (var i = 0, length = indexes.length; i < length; i++) {
        var pos = indexes[i];

        if (pos >= 0) {
          values.push(#@matches[pos]);
        }
        else {
          pos += match_length;

          if (pos > 0) {
            values.push(#@matches[pos]);
          }
          else {
            values.push(nil);
          }
        }
      }

      return values;
    }
  end
end
