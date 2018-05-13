require 'corelib/string'

class String
  def self.inherited(klass)
    replace = Class.new do
      extend String::Wrapper::ClassMethods
      include String::Wrapper::InstanceMethods
    end

    %x{
      klass.prototype         = replace.prototype;
      klass.prototype.$$class = klass;
      klass.$$parent        = #{String};

      klass.$$included_modules = replace.$$included_modules;
      klass.$$prepended_modules = replace.$$prepended_modules;

      var meta = Opal.get_singleton_class(klass);

      meta.$$included_modules = #{replace.singleton_class}.$$included_modules;
      meta.$$prepended_modules = #{replace.singleton_class}.$$prepended_modules;

      klass.$allocate = replace.$allocate;
      klass.$new      = replace.$new;

      klass.prototype.$$is_string = true;
    }
  end
end

module String::Wrapper
  module ClassMethods
    def allocate(string = '')
      obj = super()
      `obj.literal = string`
      obj
    end

    def new(*args, &block)
      obj = allocate
      obj.initialize(*args, &block)
      obj
    end

    def [](*objects)
      allocate(objects)
    end
  end

  module InstanceMethods
    def initialize(string = '')
      @literal = string
    end

    def method_missing(*args, &block)
      result = @literal.__send__(*args, &block)

      if `result.$$is_string != null`
        if `result == #{@literal}`
          self
        else
          self.class.allocate(result)
        end
      else
        result
      end
    end

    def initialize_copy(other)
      @literal = `other.literal`.clone
    end

    def respond_to?(name, *)
      super || @literal.respond_to?(name)
    end

    def ==(other)
      @literal == other
    end

    alias eql? ==
    alias === ==

    def to_s
      @literal.to_s
    end

    alias to_str to_s

    def inspect
      @literal.inspect
    end

    def +(other)
      @literal + other
    end

    def *(other)
      %x{
        var result = #{@literal * other};

        if (result.$$is_string) {
          return #{self.class.allocate(`result`)}
        }
        else {
          return result;
        }
      }
    end

    def split(pattern = undefined, limit = undefined)
      @literal.split(pattern, limit).map { |str| self.class.allocate(str) }
    end

    def replace(string)
      @literal = string
    end

    def each_line(separator = $/)
      return enum_for :each_line, separator unless block_given?
      @literal.each_line(separator) { |str| yield self.class.allocate(str) }
    end

    def lines(separator = $/, &block)
      e = each_line(separator, &block)
      block ? self : e.to_a
    end

    def %(data)
      @literal % data
    end

    def instance_variables
      super - ['@literal']
    end
  end
end
