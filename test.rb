module DuplicateM
  def repr
    self.class.name.to_s
  end
end


class Duplicate
  attr_accessor :one, :two

  def initialize(one, two)
    @one = one
    @two = two
  end

  def initialize_copy(other)
    p [self, other]
  end
end

obj = Duplicate.new(1, :a)
p ["Initial", obj]

class << obj
  include DuplicateM
end

clone = obj.clone

p ["Cloned", clone]

p clone.repr
p "KernelSpecs::Duplicate"

