class A
  class << self
    attr_accessor :emit_lambda
  end
end

class B < A
  self.emit_lambda = true
end

