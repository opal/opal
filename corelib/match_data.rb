class MatchData < Array
  attr_reader :post_match, :pre_match, :regexp, :string

  def self.new(regexp, match_groups)
    %x{
      var instance = new Opal.MatchData._alloc;
      for (var i = 0, len = match_groups.length; i < len; i++) {
        var group = match_groups[i];
        if (group == undefined) {
          instance.push(nil);
        }
        else {
          instance.push(group);
        }
      }
      instance._begin = match_groups.index;
      instance.regexp = regexp;
      instance.string = match_groups.input;
      instance.pre_match = #{$` = `instance.string.substr(0, regexp.lastIndex - instance[0].length)`};
      instance.post_match = #{$' = `instance.string.substr(regexp.lastIndex)`};
      return #{$~ = `instance`};
    }
  end

  def begin(pos)
    %x{
      if (pos == 0 || pos == 1) {
        return self._begin;
      }

      #{raise ArgumentError, 'MatchData#begin only supports 0th element'};
    }
  end

  def captures
    `self.slice(1)`
  end

  def inspect
    %x{
      var str = "#<MatchData " + #{`self[0]`.inspect};

      for (var i = 1, length = self.length; i < length; i++) {
        str += " " + i + ":" + #{`self[i]`.inspect};
      }

      return str + ">";
    }
  end

  def to_s
    `self[0]`
  end

  def to_n
    `self.valueOf()`
  end

  def values_at(*indexes)
    %x{
      var values       = [],
          match_length = self.length;

      for (var i = 0, length = indexes.length; i < length; i++) {
        var pos = indexes[i];

        if (pos >= 0) {
          values.push(self[pos]);
        }
        else {
          pos += match_length;

          if (pos > 0) {
            values.push(self[pos]);
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
