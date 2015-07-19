class Fixnum 
  MAX = 9007199254740991
  MIN = -9007199254740991

  def self.fits_in(number)
    number <= MAX && number >= MIN
  end
end
