class SubString < String
  attr_reader :special

  def initialize(str=nil)
    # raise 'DEAD'
    @special = str
  end
end

# s = SubString.new
# p s.special
# p nil
# p s
# p ""

s = SubString.new "subclass"
# p s.special
# p "subclass"
p s
# p ""
