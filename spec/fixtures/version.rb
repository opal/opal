class SpecVersion
  def >=(other)
    self.to_s >= other
  end

  def <=(other)
    self.to_s <= other
  end

  def <(other)
    self.to_s < other
  end
  def >(other)
    self.to_s > other
  end
end
