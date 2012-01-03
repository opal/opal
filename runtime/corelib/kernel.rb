module Kernel
  def =~(obj)
    false
  end

  def ===(other)
    `this == other`
  end

  def Object (object)
    Opal.native?(object) ? Native::Object.new(object) : object
  end

  def Array(object)
    return [] unless object

    unless Opal.native?(object)
      return object.to_ary if object.respond_to? :to_ary
      return object.to_a   if object.respond_to? :to_a
    end

    %x{
      var length = object.length || 0,
          result = new Array(length);

      while (length--) {
        result[length] = object[length];
      }

      return result;
    }
  end

  def at_exit(&block)
    %x{
      if (block === nil) {
        raise(RubyArgError, 'called without a block');
      }

      end_procs.push(block);

      return block;
    }
  end

  def class
    `class_real(this.$klass)`
  end

  def define_singleton_method(&body)
    %x{
      if (body === nil) {
        raise(RubyLocalJumpError, 'no block given');
      }

      $opal.ds(this, name, body);

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
    `this.$id`
  end

  def inspect
    to_s
  end

  def instance_of?(klass)
    `this.$klass === klass`
  end

  def instance_variable_defined?(name)
    `this.hasOwnProperty(name.substr(1));`
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
      var search = this.$klass;

      while (search) {
        if (search === klass) {
          return true;
        }

        search = search.$s;
      }

      return false;
    }
  end

  alias_method :kind_of?, :is_a?

  def lambda(&block)
    block
  end

  def loop(&block)
    return enum_for :loop unless block_given?

    %x{
      while (true) {
        if ($yield.call($context, null) === breaker) {
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
    `this.$id || (this.$id = unique_id++)`
  end

  def print(*strs)
    $stdout.print *strs
  end

  def proc(&block)
    block
  end

  def puts(*strs)
    $stdout.puts *strs
  end

  def raise(exception, string = undefined)
    %x{
      if (#{Opal.string?(exception)}) {
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
        raise(RubyLoadError, 'no such file to load -- ' + path);
      }

      if (LOADER_CACHE[resolved]) {
        return false;
      }

      LOADER_CACHE[resolved] = true;
      FACTORIES[resolved].call(top_self, resolved);

      return true;
    }
  end

  def respond_to?(name)
    %x{
      var meth = this[mid_to_jsid(name)];
      return !!meth;
    }
  end

  def singleton_class
    `singleton_class(this)`
  end

  def tap(&block)
    %x{
      if (block === nil) {
        raise(RubyLocalJumpError, 'no block given');
      }

      if ($yield.call($context, null, this) === breaker) {
        return breaker.$v;
      }

      return this;
    }
  end

  def to_s
    `inspect_object(this)`
  end
end
