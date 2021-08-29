class Boolean < `Boolean`
  `Opal.defineProperty(self.$$prototype, '$$is_boolean', true)`
  `Opal.defineProperty(self.$$prototype, '$$meta', #{self})`

  class << self
    def allocate
      raise TypeError, "allocator undefined for #{name}"
    end

    undef :new
  end

  def __id__
    `self.valueOf() ? 2 : 0`
  end

  alias object_id __id__

  def !
    `self != true`
  end

  def &(other)
    `(self == true) ? (other !== false && other !== nil) : false`
  end

  def |(other)
    `(self == true) ? true : (other !== false && other !== nil)`
  end

  def ^(other)
    `(self == true) ? (other === false || other === nil) : (other !== false && other !== nil)`
  end

  def ==(other)
    `(self == true) === other.valueOf()`
  end

  alias equal? ==
  alias eql? ==

  def singleton_class
    Boolean
  end

  def to_s
    `(self == true) ? 'true' : 'false'`
  end

  def dup
    self
  end

  def clone(freeze: true)
    self
  end
end

class TrueClass < Boolean
  `self.$$is_true_class = true`

  class << self
    def allocate
      raise TypeError, "allocator undefined for #{name}"
    end

    def ===(object)
      `Opal.is_obj_true(object, self)`
    end
  end
end

class FalseClass < Boolean
  `self.$$is_false_class = true`

  class << self
    def allocate
      raise TypeError, "allocator undefined for #{name}"
    end

    def ===(object)
      `Opal.is_obj_false(object, self)`
    end
  end
end

TRUE  = true
FALSE = false
