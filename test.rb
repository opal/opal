object1 = Object.new
class << object1
  CONST = 1

  def m; end
end

object1.m

object2 = object1.clone

class << object2
  p CONST
end
object2.m
