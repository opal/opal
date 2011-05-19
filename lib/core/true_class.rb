# Instances of `TrueClass` represent logically true values. There may
# only be one instance of `TrueClass`, which is the global value
# `true`. Attempts to create a new instance will yield an error.
# `TrueClass` provides methods to perform logical operations with other
# ruby objects.
#
# Implementation details
# ----------------------
#
# Due to the way messages are passed inside opal, `true` is not
# actually toll-free bridged onto the native javascript `true` value.
# In javascript, `true` and `true` are both instances of the Boolean
# type, which means they would need to share the same method_table in
# opal, which would remove their ability to be true instances of Rubys'
# `TrueClass` or `FalseClass`.
#
# As javascripts `true` is not actually the value used in opal, passing
# the native `true` value will cause errors when messages are sent to
# it. Within a file directly loaded by opal, `Qtrue` is a free variable
# that points to the actualy ruby instance of this class. This variable
# may be passed around freely.
class TrueClass
  def to_s
    "true"
  end

  def &(other)
    `return other.$r ? Qtrue : Qfalse;`
  end

  def |(other)
    true
  end

  def ^(other)
    `return other.$r ? Qfalse : Qtrue;`
  end
end

TRUE = true

