class MatchData
  def [](index)
    %x{
      var length = self.$data.length;

      if (index < 0) {
        index += length;
      }

      if (index >= length || index < 0) {
        return nil;
      }

      return self.$data[index];
    }
  end

  def length
    `self.$data.length`
  end

  def inspect
    "#<MatchData #{self[0].inspect}>"
  end

  alias_method :size, :length

  def to_a
    `[].slice.call(self.$data, 0)`
  end

  alias to_native to_a

  def to_s
    `self.$data[0]`
  end
end
