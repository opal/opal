# `Symbols` are used to represent names and can often be used in place
# of enum variables used in other languages. Symbols can be constructed
# using their literal syntax or one of the various `to_sym` methods
# found in the standard library:
#
#     :some_symbol        # => :some_symbol
#     "a_string".to_sym   # => :a_string
#
# It is important to note that regardless of the context that created
# them, two symbols with the same name will always be the exact same
# object. The opal runtime guarantees this as it creates them. If one
# exists already with the required name, it will be returned instead of
# creating a new one.
#
# Implementation details
# ----------------------
#
# Internally, symbols are just javascript strings. They are constructed
# with the javascript `new String(symbol_name)` syntax. Once created,
# they have their class and method tables altered to point towards the
# {Symbol} class. This avoids them conflicting with regular strings.
#
# Symbols are implemented as strings for performance. They are only
# created once per name, so past the initial creation phase, which
# happends just the once, they perform as quickly as just passig them
# between method calls, and as strings their native prototype offers all
# the required functionality needed by the class.
class Symbol

  def inspect
    `return ':' + self.$value;`
  end

  def to_s
    `return self.$value;`
  end

  def to_sym
    self
  end

  def intern
    self
  end
end

