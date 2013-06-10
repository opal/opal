class Native
  def self.try_convert(value)
    %x{
      if (value == null) {
        return null;
      }

      if (value.$to_n) {
        return value.$to_n()
      }
      else if (!value.$object_id) {
        return value;
      }
      else {
        return null;
      }
    }
  end

  def initialize(native)
    if (native = Native.try_convert(native)).nil?
      raise ArgumentError, "the passed value isn't a native"
    end

    @native = native
  end

  def to_n
    @native
  end
end
