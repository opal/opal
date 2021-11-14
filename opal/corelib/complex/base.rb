module ::Kernel
  def Complex(real, imag = nil)
    if imag
      Complex.new(real, imag)
    else
      Complex.new(real, 0)
    end
  end
end

class ::String
  def to_c
    Complex.from_string(self)
  end
end
