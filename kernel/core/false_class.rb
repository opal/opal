# Instances of `FalseClass` represent logically false values. There may
# only be one instance of `FalseClass`, which is the global value
# `false`. Attempts to create a new instance will yield an error.
# `FalseClass` provides methods to perform logical operations with other
# ruby objects.
#
# Implementation details
# ----------------------
#
# Due to the way messages are passed inside opal, `false` is not
# actually toll-free bridged onto the native javascript `false` value.
# In javascript, `false` and `true` are both instances of the Boolean
# type, which means they would need to share the same method_table in
# opal, which would remove their ability to be true instances of Rubys'
# `TrueClass` or `FalseClass`.
#
# As javascripts `false` is not actually the value used in opal, passing
# the native `false` value will cause errors when messages are sent to
# it. Within a file directly loaded by opal, `Qfalse` is a free variable
# that points to the actualy ruby instance of this class. This variable
# may be passed around freely.
class FalseClass

  # Returns a string representation of `false`, which is simply
  # `"false"`.
  #
  # @example
  #
  #     false.to_s    # => "false"
  #
  # @return [String]
  def to_s
    "false"
  end

  # And; This always returns `false`.
  #
  # @example
  #
  #     false & true    # => false
  #     false & nil     # => false
  #     false & false   # => false
  #
  # @return [false]
  def &(other)
    false
  end

  # Or; If `other` is `false` or `nil`, returns `false`, otherwise
  # returns `true`.
  #
  # @example
  #
  #     false & false     # => false
  #     false & nil       # => false
  #     false & true      # => true
  #     false & [1, 2, 3] # => true
  #
  # @return [true, false]
  def |(other)
    `return other.$r ? Qtrue : Qfalse;`
  end

  # Exclusive Or; If `other` is `false` or `nil`, then it returns
  # `false`, otherwise returns `true`.
  #
  # @example
  #
  #     false & false     # => false
  #     false & nil       # => false
  #     false & true      # => true
  #     false & [1, 2, 3] # => true
  #
  # @return [true, false]
  def ^(other)
    `return other.$r ? Qtrue : Qfalse;`
  end
end

FALSE = false

