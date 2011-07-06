# `Proc` objects are blocks of code that can also be bound to local
# variables in their defined scope. When called, a proc will maintain
# its `self` value, and still have the ability to access variables
# defined within the same scope. A proc may also be called in another
# context and have its `self` value tempararily adjusted.
#
# Creation of procs may be done by passing a block into the {Proc.new}
# constructor, or the {Kernel} method {Kernel#proc}:
#
#     a = Proc.new { 14 }       # => #<Proc:0x98aef>
#     b = proc { 42 + a.call }  # => #<Proc:0x98ef3>
#
#     a.call       # => 14
#     b.call       # => 56
#
# Implementation details
# ----------------------
#
# Due to their obvious similarities in functionality, a proc instance is
# simply a native javascript function allowing it to maintain access to
# variables in its outer scope, and to have its `self` value changed on
# demand.
#
# When a proc is defined, its `self` value is stored on the function
# instance itself as a `.$self` property, so when the proc is called in
# future, this is the default value passed as the self property. This
# also means that every function used in the same context as opal may be
# used as a `Proc` meaning the transition back and forth between ruby
# and javascript contexts is easy.
class Proc

  def self.new(&block)
    raise ArgumentError,
      "tried to create Proc object without a block" unless block_given?

    block
  end

  def to_proc
    self
  end

  def call(*args)
    `args.unshift(self.$proc[0]); return self.apply(null, args);`
  end

  def to_s
    `return "#<Proc:0x" + (self.$hash() * 400487).toString(16) + (self.$lambda ? ' (lambda)' : '') + ">";`
  end

  def lambda?
    `return self.$fn.$lambda ? Qtrue : Qfalse;`
  end
end

