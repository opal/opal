# The {Kernel} module is directly included into {Object} and provides a
# lot of the core object functionality.
module Kernel
  # Takes obj, which may be an opal object, or a javascript object,
  # and returns either the obj if it is already a true ruby object
  # or returns the obj wrapped in a NativeObject if it is just a
  # javascript object.
  #
  # Usage:
  #
  #     Object([1, 2, 3, 4])  # => [1, 2, 3, 4]
  #     Object(self)          # => "main"
  #     Object(`document`)    # => #<NativeObject:0x09223>
  #
  # FIXME: Depreceated?!
  #
  # @param [Object] obj native or ruby object
  # @return [Object]
  def Object (object)
    `
      if (object.$k && object.$f) {
        return object;
      }
    `

    NativeObject.new object
  end

  def =~ (obj)
    false
  end

  # raw object flags (used by runtime)
  def __flags__
    `self.$f`
  end

  def __id__
    `self.$h()`
  end

  alias_method :object_id, :__id__
  alias_method :hash, :__id__

  def class
    `return self.$k ? rb_class_real(self.$k) : #{NativeObject};`
  end

  def clone
    `
      var result = {};

      for (var property in self) {
        result[property] = self[property];
      }

      return destination;
    `
  end

  alias_method :dup, :clone

  def define_singleton_method (name, method = nil, &block)
    raise LocalJumpError, 'no block given' unless block_given?

    `VM.ds(self, #{name.to_s}, method || block);`

    nil
  end

  def extend (*mods)
    modes.each {|mod|
      `rb_extend_module(rb_singleton_class(self), mod);`
    }

    self
  end

  def instance_variable_defined? (name)
    `self.hasOwnProperty(name.substr(1))`
  end

  def instance_variable_get (name)
    `self[name = name.substr(1)] === undefined ? nil : self[name]`
  end

  def instance_variable_set (name, value)
    `self[name.substr(1)] = value`
  end

  def instance_variables
    `
      var result = [];

      for (name in self) {
        result.push(name)
      }

      return result;
    `
  end

  def instance_of? (klass)
    `self.$k == klass`
  end

  def kind_of? (klass)
    `
      var search = self.$k;

      while (search) {
        if (search == klass) {
          return true;
        }

        search = search.$super;
      }
    `

    false
  end

  alias_method :is_a?, :kind_of?

  def method (name)
    `self[#{method_id name}]`
  end

  def nil?
    false
  end

  alias_method :public_method, :method

  alias_method :public_send, :__send__

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
  def respond_to? (name)
    `!!self[#{method_id name}]`
  end

  def ===(other)
    self == other
  end

  alias_method :send, :__send__

  def singleton_class
    `rb_singleton_class(self)`
  end

  def methods
    `self.$k.$methods`
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
  def rand (max = `undefined`)
    `
      if (max != undefined) {
        return Math.floor(Math.random() * max);
      }
      else {
        return Math.random();
      }
    `
  end

  # Returns a simple string representation of the receiver object. The id shown in the string
  # is not just the object_id, but it is mangled to resemble the format output by ruby, which
  # is basically a hex number.
  #
  # FIXME: proper hex output needed
  def to_s
    "#<#{`rb_class_real(self.$k)`}:0x#{`(self.$h() * 400487).toString(16)`}>"
  end

  def inspect
    to_s
  end

  def const_set (name, value)
    `rb_const_set(rb_class_real(self.$k), name, value)`
  end

  def const_defined?(name)
    false
  end

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
  def raise (exception, string = nil)
    `
      var msg = nil, exc;

      if (exception.$f & T_STRING) {
        msg = exception;
        exc = #{RuntimeError.new `msg`};
      }
      else if (#{`exception`.is_a? Exception}) {
        exc = exception;
      }
      else {
        if (string != nil) {
          msg = string;
        }

        exc = #{`exception`.new `msg`};
      }

      rb_raise_exc(exc);
    `
  end

  alias_method :fail, :raise

  # Try to load the library or file named `path`. An error is thrown if the
  # path cannot be resolved.
  #
  # @param [String] path The path to load
  # @return [true, false]
  def require (path)
    `rb_require(path)`
  end

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
    while true
      yield
    end

    self
  end

  # Executed in reverse order
  def at_exit (&block)
    raise ArgumentError, 'called without a block' unless block_given?

    `rb_end_procs.push(block);`

    block
  end

  def exit status
    # do something?
  end

  # Simple equivalent to `Proc.new`. Returns a new proc from the given block.
  #
  # @example
  #
  #     proc { puts "a" }
  #     # => #<Proc 02002>
  #
  # @return [Proc]
  def proc (&block)
    raise ArgumentError, 'tried to create Proc object without a block' unless block_given?

    block
  end

  def lambda (&block)
    raise ArgumentError, 'tried to create Proc object without a block' unless block_given?

    `rb_make_lambda(block)`
  end

  def method_id (name)
    `"m$" + name`
  end

  def tap
    raise LocalJumpError, 'no block given' unless block_given?

    yield self

    self
  end

  def private; end
  def public; end
  def protected; end
end

