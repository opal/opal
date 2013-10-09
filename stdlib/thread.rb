class Thread
  def self.current
    @current ||= self.new
  end

  def initialize
    @vars = {}
  end

  def [](key)
    @vars[key]
  end

  def []=(key, val)
    @vars[key] = val
  end
end
