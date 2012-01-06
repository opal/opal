class Numeric
  def seconds
    self
  end; alias second seconds

  def minutes
    self * 60
  end; alias minute minutes

  def hours
    self * 60.minutes
  end; alias hour hours

  def days
    self * 24.hours
  end; alias day days
end
