o = Object.new
class << o
  CONST = 123
end

o = o.clone

class << o
  p CONST
end
