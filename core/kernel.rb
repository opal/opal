module Kernel
  def =~(obj)
    false
  end

  def ==(other)
    `#{self} === other`
  end

  def ===(other)
    `#{self} == other`
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
    `return #{self}.$k`
  end

  def define_singleton_method(name, &body)
    %x{
      if (body === nil) {
        no_block_given();
      }

      var jsid   = '$' + name;
      body._jsid = jsid;
      body._sup  = #{self}[jsid]

      #{self}[jsid] = body;

      return #{self};
    }
  end

  def equal?(other)
    `#{self} === other`
  end

  def extend(*mods)
    %x{
      for (var i = 0, length = mods.length; i < length; i++) {
        #{ self.singleton_class.include `mods[i]` };
      }

      return #{self};
    }
  end

  def hash
    `#{self}._id`
  end

  def inspect
    to_s
  end

  def instance_of?(klass)
    `#{self}.$k === klass`
  end

  def instance_variable_defined?(name)
    `__hasOwn.call(#{self}, name.substr(1))`
  end

  def instance_variable_get(name)
    %x{
      var ivar = #{self}[name.substr(1)];

      return ivar == null ? nil : ivar;
    }
  end

  def instance_variable_set(name, value)
    `#{self}[name.substr(1)] = value`
  end

  def instance_variables
    %x{
      var result = [];

      for (var name in #{self}) {
        result.push(name);
      }

      return result;
    }
  end

  def is_a?(klass)
    %x{
      var search = #{self}.$k;

      while (search) {
        if (search === klass) {
          return true;
        }

        search = search.$s;
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

    `while (true) {`
      yield
    `}`

    self
  end

  def nil?
    false
  end

  def object_id
    `#{self}._id || (#{self}._id = unique_id++)`
  end

  def proc(&block)
    %x{
      if (block === nil) {
        no_block_given();
      }
      block.is_lambda = false;
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
    `!!#{self}['$' + name]`
  end

  def singleton_class
    %x{
      if (!#{self}._isObject) {
        return #{self}.$k;
      }

      if (#{self}._singleton) {
        return #{self}._singleton;
      }

      else {
        var orig_class = #{self}.$k,
            class_id   = "#<Class:#<" + orig_class._name + ":" + orig_class._id + ">>";

        function Singleton() {};
        var meta = boot_class(orig_class, Singleton);
        meta._name = class_id;

        #{self}.$m = meta.$m_tbl;
        #{self}._singleton = meta;
        meta.$k = orig_class.$k;

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
    `return "#<" + #{self}._klass._name + ":" + #{self}._id + ">";`
  end

  def enum_for (method = :each, *args)
    Enumerator.new(self, method, *args)
  end

  alias to_enum enum_for
end