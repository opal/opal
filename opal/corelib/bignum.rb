# backtick_javascript: true
# use_strict: true

class ::Bignum < ::Number
  def self.supported?
    `typeof BigInt !== "undefined"`
  end

  Opal.bridge(`BigInt`, self) if supported?
  `Opal.prop(self.$$prototype, '$$is_bignum', true)`
  # Technically this is not a number, it has different properties.
  `Opal.prop(self.$$prototype, '$$is_number', false)`
  `self.$$is_integer_class = false`
  `var number_id_map = new Map()`

  def __id__
    %x{
      if (number_id_map.has(self)) {
        return number_id_map.get(self);
      }
      var id = Opal.uid();
      number_id_map.set(self, id);
      return id;
    }
  end

  def hash
    `self.toString().$hash()`
  end

  def to_s
    `self.toString()`
  end

  def coerce(other)
    %x{
      if (other === nil) {
        #{raise TypeError, "can't convert #{other.class} into Bignum"};
      }
      else if (other.$$is_number && !#{other.integer?}) {
        return [other, #{to_f}]
      }
      else if (#{other.respond_to?(:to_bn)}) {
        return [#{Opal.coerce_to!(other, Bignum, :to_bn)}, self];
      }
      else {
        #{raise TypeError, "can't convert #{other.class} into Float"};
      }
    }
  end

  alias +@ itself

  def +(other)
    %x{
      if (other.$$is_bignum) {
        return self + other;
      }
      else {
        return #{__coerced__ :+, other};
      }
    }
  end

  def -(other)
    %x{
      if (other.$$is_bignum) {
        return self - other;
      }
      else {
        return #{__coerced__ :-, other};
      }
    }
  end

  def *(other)
    %x{
      if (other.$$is_bignum) {
        return self * other;
      }
      else {
        return #{__coerced__ :*, other};
      }
    }
  end

  def /(other)
    %x{
      if (other.$$is_bignum) {
        return self / other;
      }
      else {
        return #{__coerced__ :/, other};
      }
    }
  end

  alias fdiv /

  def %(other)
    %x{
      if (other.$$is_bignum) {
        return self % other;
      }
      else {
        return #{__coerced__ :%, other};
      }
    }
  end

  def &(other)
    %x{
      if (other.$$is_bignum) {
        return self & other;
      }
      else {
        return #{__coerced__ :&, other};
      }
    }
  end

  def |(other)
    %x{
      if (other.$$is_bignum) {
        return self | other;
      }
      else {
        return #{__coerced__ :|, other};
      }
    }
  end

  def ^(other)
    %x{
      if (other.$$is_bignum) {
        return self ^ other;
      }
      else {
        return #{__coerced__ :^, other};
      }
    }
  end

  def **(other)
    %x{
      if (other.$$is_bignum) {
        return self ** other;
      }
      else {
        return #{__coerced__ :**, other};
      }
    }
  end

  def >>(other)
    %x{
      if (other.$$is_bignum) {
        return self >> other;
      }
      else {
        return #{__coerced__ :>>, other};
      }
    }
  end

  def <<(other)
    %x{
      if (other.$$is_bignum) {
        return self << other;
      }
      else {
        return #{__coerced__ :<<, other};
      }
    }
  end

  def equal?(other)
    %x{
      if (other.$$is_bignum) {
        return self == other;
      }
      else if (`other.integer?`) {
        return self == #{other.to_bn};
      }
      else {
        return false
      }
    }
  end

  def abs
    self < 0 ? -self : self
  end

  def infinity?
    false
  end
  alias nan? infinite?

  def integer?
    true
  end
  alias finite? integer?

  def positive?
    `self > 0`
  end

  def negative?
    `self < 0`
  end

  def even?
    `self % BigInt(2) === BigInt(0)`
  end

  def odd?
    !even?
  end

  alias to_bn itself

  def size
    (Math.log(self, 2) / 8).ceil
  end

  def to_f
    `Number(self)`
  end

  alias to_i itself
  alias to_int itself

  alias inspect to_s
end

class Number
  if Bignum.supported?
    def to_bn
      `BigInt(#{to_i})`
    end
  else
    def to_bn
      to_i
    end
  end
end

class String
  if Bignum.supported?
    def to_bn
      `BigInt(self)`
    end
  else
    def to_bn
      to_i
    end
  end
end

module Kernel
  def Bignum(value)
    value.to_bn
  end
end
