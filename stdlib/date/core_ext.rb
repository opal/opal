class Time
  def to_date
    Date.wrap(self)
  end

  def to_datetime
    DateTime.wrap(self)
  end
end
