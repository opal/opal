class Range

  def begin
    `return self.$beg;`
  end

  alias_method :first, :begin

  def end
    `return self.$end;`
  end

  def to_s
    `var str = #{`self.$beg`.to_s};
    var str2 = #{`self.$end`.to_s};
    var join = self.$exc ? '...' : '..';
    return str + join + str2;`
  end

  def inspect
    `var str = #{`self.$beg`.inspect};
    var str2 = #{`self.$end`.inspect};
    var join = self.$exc ? '...' : '..';
    return str + join + str2;`
  end
end

