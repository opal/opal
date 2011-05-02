# `NilClass` has a single instance `nil`. No more instances of this
# class can be created, and attempts to do so will yield an error.
#
# Implementation details
# ----------------------
#
# `nil` is an actual ruby object, and is not just a reference to the
# native `null` or `undefined` values in javascript. Sending messages to
# `nil` in ruby is a very useful feature of ruby, and this would not be
# possible in opal if `nil` was just the `null` or `undefined` value.
#
# To access `nil` from javascript, `Qnil` points to this instance and is
# available in both ruby and javascript sources loaded by opal.
class NilClass

  def to_i
    0
  end

  def to_f
    0.0
  end

  def to_s
    ""
  end

  def to_a
    []
  end

  def inspect
    "nil"
  end

  def nil?
    true
  end

  def &(other)
    false
  end

  def |(other)
    `return other.$r ? Qtrue : Qfalse;`
  end

  def ^(other)
    `return other.$r ? Qtrue : Qfalse;`
  end
end

NIL = nil

