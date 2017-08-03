class Boolean < `Boolean`
  `def.$$is_boolean = true`
  `def.$$meta = #{self}`

  class << self
    def allocate
      raise TypeError, "allocator undefined for #{self.name}"
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
    raise TypeError, "can't dup #{self.class}"
  end

  def clone
    raise TypeError, "can't clone #{self.class}"
  end
end

TrueClass  = Boolean
FalseClass = Boolean

TRUE  = true
FALSE = false
