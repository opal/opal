module Kernel
  def Array(object)
    return [] unless object

    if Object === object
      return object.to_ary if object.respond_to? :to_ary
      return object.to_a   if object.respond_to? :to_a
    end

    `
      var length = object.length || 0,
          result = new Array(length);

      while (length--) {
        result[length] = object[length];
      }

      return result;
    `
  end

  def Complex(x, y = undefined)
    Complex.new(x, y)
  end

  def Float(arg)
    arg.to_f
  end

  def Integer(arg, base = 10)
    arg.to_i(base)
  end

  def Rational(x, y = undefined)
    Rational.new(x, y)
  end

  def String(arg)
    arg.to_s
  end

  # raw object flags (used by runtime)
  def __flags__
    `self.o$f`
  end

  def hash
    `return self.$id;`
  end

  def =~(obj)
    false
  end

  alias_method :object_id, :hash
  alias_method :__id__, :hash

  def class
    `rb_class_real(self.o$k)`
  end

  def define_singleton_method(name, &block)
    raise LocalJumpError, 'no block given' unless block

    `$rb.ds(self, #{name.to_s}, block);`

    nil
  end

  def extend(*mods)
    modes.each {|mod|
      `rb_extend_module(rb_singleton_class(self), mod);`
    }

    self
  end

  def instance_variable_defined?(name)
    `self.hasOwnProperty(name.substr(1))`
  end

  def instance_variable_get(name)
    `self[name = name.substr(1)]`
  end

  def instance_variable_set(name, value)
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

  def instance_of?(klass)
    `self.o$k == klass`
  end

  def kind_of?(klass)
    `
      var search = self.o$k;

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

  def method(name)
    `return self.$m[name];`
  end

  def nil?
    false
  end

  alias_method :public_method, :method

  alias_method :public_send, :__send__

  def puts(*strs)
    $stdout.puts *strs
  end

  def print(*strs)
    $stdout.print *strs
  end

  def respond_to?(name)
    `
      var meth = self[STR_TO_ID_TBL[name]];

      if (meth && !meth.$method_missing) {
        return true;
      }

      return false;
    `
  end

  def ===(other)
    self == other
  end

  alias_method :send, :__send__

  def singleton_class
    `rb_singleton_class(self)`
  end

  def rand(max = undefined)
    `
      if (max !== undefined) {
        return Math.floor(Math.random() * max);
      }
      else {
        return Math.random();
      }
    `
  end

  # FIXME: proper hex output needed
  def to_s
    `rb_inspect_object(self)`
  end

  def inspect
    to_s
  end

  def const_set(name, value)
    `rb_const_set(rb_class_real(self.o$k), name, value)`
  end

  def const_defined?(name)
    false
  end

  def raise(exception, string = nil)
    `
      var message, msg, exc;

      if (typeof(exception) === 'string') {
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

      throw exc;
    `
  end

  alias_method :fail, :raise

  def require(path)
    `
      var resolved = rb_find_lib(path);

      if (!resolved) {
        rb_raise(rb_eLoadError, "no such file to load -- " + path);
      }

      if (LOADER_CACHE[resolved]) {
        return false;
      }

      LOADER_CACHE[resolved] = true;
      LOADER_FACTORIES[resolved](rb_top_self, resolved);

      return true;
    `
  end

  def loop
    while true
      yield
    end

    self
  end

  def at_exit(&block)
    raise ArgumentError, 'called without a block' unless block_given?

    `rb_end_procs.push(block);`

    block
  end

  def proc(&block)
    raise ArgumentError, 'tried to create Proc object without a block' unless block_given?

    block
  end

  def lambda(&block)
    raise ArgumentError, 'tried to create Proc object without a block' unless block_given?

    `rb_make_lambda(block)`
  end

  def tap
    raise LocalJumpError, 'no block given' unless block_given?

    yield self

    self
  end
end

class Object
  include Kernel
end
