class Numeric

  def +(other)
    %x{
      if (other.$$is_number) {
        return #{handle_overflow :+, other, `self + other`};
      }
      else {
        return #{send_coerced :+, other};
      }
    }
  end

  def -(other)
    %x{
      if (other.$$is_number) {
        return #{handle_overflow :-, other, `self - other`};
      }
      else {
        return #{send_coerced :-, other};
      }
    }
  end

  def *(other)
    %x{
      if (other.$$is_number) {
        return #{handle_overflow :*, other, `self * other`};
      }
      else {
        return #{send_coerced :*, other};
      }
    }
  end

  def **(other)
    %x{
      if (other.$$is_number) {
        return #{handle_overflow :**, other, `Math.pow(self, other)`};
      }
      else {
        return #{send_coerced :**, other};
      }
    }
  end

  def handle_overflow(method, other, result)
    return result if !self.integer? || !other.integer? || Fixnum.fits_in(result)
    Bignum.create_bignum(self).send method, other
  end


  def <<(count)
    Bignum.create_bignum(self) << count
  end

  def >>(count)
    Bignum.create_bignum(self) >> count
  end

  def next
    self + 1
  end

  def pred
    self - 1
  end
end

class Integer 
  def self.===(other)
    return true if other.instance_of? Bignum
    %x{
      if (!other.$$is_number) {
        return false;
      }

      return (other % 1) === 0;
    }
  end
end
