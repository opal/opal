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
    "#<MatchData #{`this[0]`.inspect}>"
  end

  alias size length

  def to_a
    `__slice.call(this.$data)`
  end

  def to_s
    `this.$data[0]`
  end
end