class Boolean < `Boolean`
  `Opal.defineProperty(self[Opal.s.$$prototype], Opal.s.$$is_boolean, true)`
  `Opal.defineProperty(self[Opal.s.$$prototype], Opal.s.$$meta, #{self})`

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

TrueClass  = Boolean
FalseClass = Boolean

TRUE  = true
FALSE = false
