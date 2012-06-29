module Kernel
  def =~(obj)
    false
  end

  def ==(other)
    `this === other`
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
    `return this._klass`
  end

  def define_singleton_method(name, &body)
    %x{
      if (body === nil) {
        no_block_given();
      }

      var jsid = mid_to_jsid(name);
      body._jsid = jsid;
      body._sup  = this[jsid]

      this[jsid] = body;

      return this;
    }
  end

  def equal?(other)
    `this === other`
  end

  def extend(*mods)
    %x{
      for (var i = 0, length = mods.length; i < length; i++) {
        this.$singleton_class().$include(mods[i]);
      }

      return this;
    }
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

      return ivar == null ? nil : ivar;
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
          return __breaker.$v;
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

  def proc(&block)
    %x{
      if (block === nil) {
        no_block_given();
      }

      return block;
    }
  end

  def puts(*strs)
    %x{
      for (var i = 0; i < strs.length; i++) {
        console.log(#{ `strs[i]`.to_s });
      }
    }
    nil
  end

  alias print puts

  def raise(exception, string)
    %x{
      if (typeof(exception) === 'string') {
        exception = #{RuntimeError.new exception};
      }
      else if (!#{exception.is_a? Exception}) {
        exception = #{exception.new string};
      }

      throw exception;
    }
  end

  def rand(max)
    `max == null ? Math.random() : Math.floor(Math.random() * max)`
  end

  def respond_to?(name)
    `!!this[mid_to_jsid(name)]`
  end

  def singleton_class
    %x{
      if (!this._isObject) {
        return this._klass;
      }

      if (this._klass._isSingleton) {
        return this._klass;
      }
      else {
        var orig_class = this._klass,
            class_id   = "#<Class:#<" + orig_class._name + ":" + orig_class._id + ">>";

        function _Singleton() {};
        var meta = boot_class(orig_class, _Singleton);
        meta._name = class_id;

        meta._isSingleton = true;
        meta.prototype = this;
        this._klass = meta;
        meta._klass = orig_class._klass;

        return meta;
      }
    }
  end

  def tap(&block)
    `if (block === nil) no_block_given();`

    yield self
    self
  end

  def to_json
    to_s.to_json
  end

  def to_proc
    self
  end

  def to_s
    `return "#<" + this._klass._klass._name + ":0x" + (this._id * 400487).toString(16) + ">";`
  end

  def enum_for (method = :each, *args)
    Enumerator.new(self, method, *args)
  end

  alias to_enum enum_for
end