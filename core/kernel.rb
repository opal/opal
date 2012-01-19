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

  def at_exit(&block)
    %x{
      if (block === nil) {
        throw RubyArgError.$new('called without a block');
      }

      end_procs.push(block);

      return block;
    }
  end

  def class
    `class_real(this.o$klass)`
  end

  def define_singleton_method(name, &body)
    %x{
      if (body === nil) {
        throw RubyLocalJumpError.$new('no block given');
      }

      $opal.defs(this, mid_to_jsid(name), body);

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

  def hash
    `this.o$id`
  end

  def inspect
    to_s
  end

  def instance_of?(klass)
    `this.o$klass === klass`
  end

  def instance_variable_defined?(name)
    `hasOwnProperty.call(this, name.substr(1))`
  end

  def instance_variable_get(name)
    %x{
      var ivar = this[name.substr(1)];

      return ivar == undefined ? nil : ivar;
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
      var search = this.o$klass;

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

    %x{
      while (true) {
        if ($yield.call($context) === breaker) {
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
    `this.o$id || (this.o$id = unique_id++)`
  end

  def print(*strs)
    $stdout.print *strs
  end

  def private(*)
  end

  def proc(&block)
    block
  end

  def protected(*)
  end

  def public(*)
  end

  def puts(*strs)
    $stdout.puts *strs
  end

  def raise(exception, string = undefined)
    %x{
      if (typeof(exception) === 'string') {
        exception = #{`RubyRuntimeError`.new `exception`};
      }
      else if (#{!exception.is_a? `RubyException`}) {
        exception = #{`exception`.new string};
      }

      throw exception;
    }
  end

  def rand(max = undefined)
    `max === undefined ? Math.random() : Math.floor(Math.random() * max)`
  end

  def require(path)
    %x{
      var resolved = find_lib(path);

      if (!resolved) {
        throw RubyLoadError.$new('no such file to load -- ' + path);
      }

      if (LOADER_CACHE[resolved]) {
        return false;
      }

      LOADER_CACHE[resolved] = true;
      FEATURES.push(resolved);
      $opal.FILE = resolved;
      FACTORIES[resolved].call(opal.top, opal);

      return true;
    }
  end

  def respond_to?(name)
    `!!this[mid_to_jsid(name)]`
  end

  def singleton_class
    %x{
      var obj = this, klass;

      if (obj.o$flags & T_OBJECT) {
        if ((obj.o$flags & T_NUMBER) || (obj.o$flags & T_STRING)) {
          throw RubyTypeError.$new("can't define singleton");
        }
      }

      if ((obj.o$klass.o$flags & FL_SINGLETON) && obj.o$klass.__attached__ == obj) {
        klass = obj.o$klass;
      }
      else {
        var class_id = obj.o$klass.o$name;

        klass = make_metaclass(obj, obj.o$klass);
      }

      return klass;
    }
  end

  def tap(&block)
    %x{
      if (block === nil) {
        throw RubyLocalJumpError.$new('no block given');
      }

      if ($yield.call($context, this) === breaker) {
        return breaker.$v;
      }

      return this;
    }
  end

  def to_s
    `return "#<" + class_real(this.o$klass).o$name + ":0x" + (this.o$id * 400487).toString(16) + ">";`
  end
end
