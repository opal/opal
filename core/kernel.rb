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

  def __send__(symbol, *args, &block)
    %x{
      return #{self}['$' + symbol].apply(#{self}, args);
    }
  end

  alias eql? ==

  def Array(object)
    %x{
      if (object.$to_ary) {
        return #{object.to_ary};
      }
      else if (object.$to_a) {
        return #{object.to_a};
      }

      return [object];
    }
  end

  def attribute_get(name)
    %x{
      var meth = '$' + name;
      if (#{self}[meth]) {
        return #{self}[meth]();
      }

      meth += '?';
      if (#{self}[meth]) {
        return #{self}[meth]()
      }

      return nil;
    }
  end

  def attribute_set(name, value)
  %x{
    if (#{self}['$' + name + '=']) {
      return #{self}['$' + name + '='](value);
    }

    return nil;
  }
  end

  def class
    `return #{self}._klass`
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

  def initialize(*)
  end

  def inspect
    to_s
  end

  def instance_eval(string=undefined, &block)
    %x{
      if (block === nil) {
        no_block_given();
      }

      return block.call(#{self}, #{self});
    }
  end

  def instance_exec(*args, &block)
    %x{
      if (block === nil) {
        no_block_given();
      }

      return block.apply(#{self}, args);
    }
  end

  def instance_of?(klass)
    `#{self}._klass === klass`
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
      var search = #{self}._klass;

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
        if(strs[i] instanceof Array) {
          #{ puts *strs }
        } else {
          __opal.puts(#{ `strs[i]`.to_s });
        }
      }
    }
    nil
  end

  def p(*args)
    `console.log.apply(console, args);`
    args
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

  alias send __send__

  def singleton_class
    %x{
      if (#{self}._isClass) {
        if (#{self}._singleton) {
          return #{self}._singleton;
        }

        var meta = new __opal.Class;
        meta._klass = __opal.Class;
        #{self}._singleton = meta;
        meta.prototype = #{self};

        return meta;
      }

      if (!#{self}._isObject) {
        return #{self}._klass;
      }

      if (#{self}._singleton) {
        return #{self}._singleton;
      }

      else {
        var orig_class = #{self}._klass,
            class_id   = "#<Class:#<" + orig_class._name + ":" + orig_class._id + ">>";

        function Singleton() {};
        var meta = boot_class(orig_class, Singleton);
        meta._name = class_id;

        meta.prototype = #{self};
        #{self}._singleton = meta;
        meta._klass = orig_class._klass;

        return meta;
      }
    }
  end

  def tap(&block)
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
end