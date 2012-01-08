class MatchData
  def [](index)
    %x{
      var length = this.$data.length;

      if (index < 0) {
        index += length;
      }

      if (index >= length || index < 0) {
        return nil;
      }

      return this.$data[index];
    }
  end

  def length
    `this.$data.length`
  end

  def inspect
    "#<MatchData #{self[0].inspect}>"
  end

  alias size length

  def to_a
    `[].slice.call(this.$data, 0)`
  end

  def to_s
    `this.$data[0]`
  end
end
