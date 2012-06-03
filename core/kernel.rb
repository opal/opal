module Kernel
  def =~(obj)
    false
  end

  def ===(other)
    `this == other`
  end

  def Array(object)
    return [] unless object

    %x{
      if (object.$to_ary) {
        return #{object.to_ary};
      }
      else if (object.$to_a) {
        return #{object.to_a};
      }

      var length = object.length || 0,
          result = [];

      while (length--) {
        result[length] = object[length];
      }

      return result;
    }
  end

  def class
    `return this._real`
  end

  def define_singleton_method(name, &body)
    %x{
      if (body == null) {
        no_block_given();
      }

      // FIXME: need to donate()
      this.$singleton_class()._proto[mid_to_jsid(name)] = body;

      return this;
    }
  end

  def equal?(other)
    `this === other`
  end

  def extend(*mods)
    %x{
      for (var i = 0, length = mods.length; i < length; i++) {
        include_module(singleton_class(this), mods[i]);
      }

      return this;
    }
  end

  def format(string, *arguments)
    raise NotImplementedError
  end

  def hash
    `this._id`
  end

  def inspect
    to_s
  end

  def instance_of?(klass)
    `this._klass === klass`
  end

  def instance_variable_defined?(name)
    `__hasOwn.call(this, name.substr(1))`
  end

  def instance_variable_get(name)
    %x{
      var ivar = this[name.substr(1)];

      return ivar == null ? null : ivar;
    }
  end

  def instance_variable_set(name, value)
    `this[name.substr(1)] = value`
  end

  def instance_variables
    %x{
      var result = [];

      for (var name in this) {
        result.push(name);
      }

      return result;
    }
  end

  def is_a?(klass)
    %x{
      var search = this._klass;

      while (search) {
        if (search === klass) {
          return true;
        }

        search = search._super;
      }

      return false;
    }
  end

  alias kind_of? is_a?

  def lambda(&block)
    block
  end

  def loop(&block)
    return enum_for :loop unless block_given?

    %x{
      while (true) {
        if (block.call(__context) === __breaker) {
          return breaker.$v;
        }
      }

      return this;
    }
  end

  def nil?
    false
  end

  def object_id
    `this._id || (this._id = unique_id++)`
  end

  def print(*strs)
    puts *strs
  end

  def private(*)
    # does nothing. here for documenting code
  end

  def proc(&block)
    %x{
      if (block == null) {
        no_block_given();
      }

      return block;
    }
  end

  def protected(*)
    # does nothing. here for documenting code
  end

  def public(*)
    # does nothing. here for documenting code
  end

  def puts(*strs)
    %x{
      for (var i = 0; i < strs.length; i++) {
        var obj = strs[i];
        console.log(#{ `obj`.to_s });
      }
    }
    nil
  end

  alias sprintf format

  def raise(exception, string = undefined)
    %x{
      if (typeof(exception) === 'string') {
        exception = #{RuntimeError.new exception};
      }
      else if (#{!exception.is_a? Exception}) {
        exception = #{`exception`.new string};
      }

      throw exception;
    }
  end

  def rand(max = undefined)
    `max === undefined ? Math.random() : Math.floor(Math.random() * max)`
  end

  def require(path)
    `Opal.require(path)`
  end

  def respond_to?(name)
    `!!this[mid_to_jsid(name)]`
  end

  def singleton_class
    %x{
      var obj = this, klass;

      if (obj._isObject) {
        if (obj._isNumber || obj._isString) {
          throw RubyTypeError.$new("can't define singleton");
        }
      }

      if ((obj._klass._isSingleton) && obj._klass.__attached__ == obj) {
        klass = obj._klass;
      }
      else {
        var class_id = obj._klass._name;
        klass = make_metaclass(obj, obj._klass);
      }

      return klass;
    }
  end

  def tap(&block)
    %x{
      if (block == null) {
        no_block_given();
      }

      if (block.call(__context, this) === __breaker) {
        return __breaker.$v;
      }

      return this;
    }
  end

  def to_proc
    self
  end

  def to_s
    `return "#<" + this._klass._real._name + ":0x" + (this._id * 400487).toString(16) + ">";`
  end
end
