# The {Kernel} module is directly included into {Object} and provides a
# lot of the core object functionality. It is not, however, included in
# {BasicObject}.
module Kernel


  def instance_variable_defined?(name)
    `name = #{name.to_s};
    return self[name] == undefined ? Qfalse : Qtrue;`
  end

  def instance_variable_get(name)
    `name = #{name.to_s};
    return self[name] == undefined ? nil : self[name];`
  end

  def instance_variable_set(name, value)
    `name = #{name.to_s};
    return self[name] = value;`
  end

  # Returns `true` if a block was given to the current method, `false`
  # otherwise.
  #
  # @NOTE: In opal, this is actually a fake method. block_given? is inlined
  # for efficiency and implementation details.
  #
  # @return [true, false]
  def block_given?
    false
  end

  # raw object flags (used by runtime)
  def __flags__
    `return self.$flags;`
  end

  def to_a
    [self]
  end

  def tap
    raise LocalJumpError, "no block given" unless block_given?
    yield self
    self
  end

  def kind_of?(klass)
    `var search = self.$klass;

    while (search) {
      if (search == klass) {
        return Qtrue;
      }

      search = search.$super;
    }

    return Qfalse;`
  end

  def is_a?(klass)
    kind_of? klass
  end

  def nil?
    false
  end

  # Returns `true` if the method with the given id exists on the receiver,
  # `false` otherwise.
  #
  # Implementation Details
  # ----------------------
  # Opals' internals are constructed so that when a method is initially called,
  # a fake method is created on the root basic object, so that any subsequent
  # calls to that method on an object that has not defined it, will yield a
  # method_missing behaviour. For this reason, fake methods are tagged with a
  # `.$rbMM` property so that they will not be counted when this method checks
  # if a given method has been defined.
  #
  # @param [String, Symbol] method_id
  # @return [Boolean]
  def respond_to?(method_id)
    `var method = self['m$' + #{`method_id`.to_s}];

    if (method && !method.$rbMM) {
      return Qtrue;
    }

    return Qfalse;`
  end

  def ===(other)
    self == other
  end

  def send(method_id, *args, &block)
    `var method = self.$m[#{method_id.to_s}];

    if ($B.f == arguments.callee) {
      $B.f = method;
    }

    args.unshift(self);

    return method.apply(self, args);`
  end

  def class
    `return $rb.class_real(self.$klass);`
  end

  def singleton_class
    `return $rb.singleton_class(self);`
  end

  def methods
    `return self.$klass.$methods;`
  end

  # Returns a random number. If max is `nil`, then the result is 0. Otherwise
  # returns a random number between 0 and max.
  #
  # @example
  #
  #     rand        # => 0.918378392234
  #     rand        # => 0.283842929289
  #     rand 10     # => 9
  #     rand 100    # => 21
  #
  # @param [Numeric] max
  # @return [Numeric]
  def rand(max = `undefined`)
    `if (max != undefined)
        return Math.floor(Math.random() * max);
    else
      return Math.random();`
  end

  def __id__
    `return self.$hash();`
  end

  def object_id
    `return self.$hash();`
  end

  # Returns a simple string representation of the receiver object. The id shown in the string
  # is not just the object_id, but it is mangled to resemble the format output by ruby, which
  # is basically a hex number.
  #
  # FIXME: proper hex output needed
  def to_s
    "#<#{`$rb.class_real(self.$klass)`}:0x#{`(self.$hash() * 400487).toString(16)`}>"
  end

  def inspect
    to_s
  end

  def const_set(name, value)
    `return rb_const_set($rb.class_real(self.$klass), name, value);`
  end

  def const_defined?(name)
    false
  end

  def =~(obj)
    nil
  end

  def extend(mod)
    `$rb.extend_module($rb.singleton_class(self), mod);`
    nil
  end

  # @group Private methods
  private

  # Raises an exception. If given a string, this method will raise a
  # RuntimeError with the given string as a message. Otherwise, if the first
  # parameter is a subclass of Exception, then the method will raise a new
  # instance of the given exception class with the string as a message, if it
  # exists, or a fdefault message otherwise.
  #
  # @example String message
  #
  #     raise "some error"
  #     # => RuntimeError: some error
  #
  # @example Exception subclass
  #
  #     raise StandardError, "something went wrong"
  #     # => StandardError: something went wrong
  #
  # @param [Exception, String] exception
  # @param [String]
  # @return [nil]
  def raise(exception, string = nil)
    `var msg = nil, exc;

    if (typeof exception == 'string') {
      msg = exception;
      exc = #{RuntimeError.new `msg`};
    } else if (#{`exception`.kind_of? Exception}.$r) {
      exc = exception;
    } else {
      if (string != nil) msg = string;
      exc = #{`exception`.new `msg`};
    }
    $rb.raise_exc(exc);`
  end

  alias_method :fail, :raise

  # Repeatedly executes the given block.
  #
  # @example
  #
  #     loop do
  #       puts "this will infinetly repeat"
  #     end
  #
  # @return [Object] returns the receiver.
  def loop
    `while (true) {
      #{yield};
    }

    return self;`
  end

  # Simple equivalent to `Proc.new`. Returns a new proc from the given block.
  #
  # @example
  #
  #     proc { puts "a" }
  #     # => #<Proc 02002>
  #
  # @return [Proc]
  def proc(&block)
    raise ArgumentError,
      "tried to create Proc object without a block" unless block_given?
    block
  end

  def lambda(&block)
    raise ArgumentError,
      "tried to create Proc object without a block" unless block_given?
    `return $rb.lambda(block);`
  end

  # @endgroup
end

