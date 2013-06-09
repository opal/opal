class Native
  def initialize(native)
    @native = `native.$to_n ? native.$to_n() : native`
  end

  def to_n
    @native
  end
end
