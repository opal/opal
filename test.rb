# binary_plus = Class.new(String) do
#   alias_method :plus, :+
#   def +(a)
#     plus(a) + "!"
#   end
# end
# s = binary_plus.new("a")


# require 'pry'; binding.pry


# p s + s + s


class MyString1 < String
  def my1
  end
end

class MyString2 < String
  def my2
  end
end

s1 = MyString1.new("one")
s2 = MyString2.new("two")

`debugger`

123
