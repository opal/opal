class Time
  def self.parse(str)
    `new Date(Date.parse(str))`
  end

  def iso8601
    strftime('%FT%T%z')
  end
end
