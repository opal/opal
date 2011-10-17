class MatchData
  def inspect
    "#<MatchData #{`self.$data[0]`.inspect}>"
  end

  def to_s
    `self.$data[0]`
  end

  def length
    `self.$data.length`
  end

  def size
    `self.$data.length`
  end

  def to_a
    `[].slice.call(self.$data, 0)`
  end

  def [] (index)
    `
      var length = self.$data.length;

      if (index < 0) {
        index += length;
      }

      if (index >= length || index < 0) {
        return nil;
      }

      return self.$data[index];
    `
  end
end

