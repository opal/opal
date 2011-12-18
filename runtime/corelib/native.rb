module Native
  class Object
    include Native

    def [] (name)
      `#@native[name]`
    end

    def []= (name, value)
      `#@native[name] = value`
    end

    def nil?
      `#@native === null || #@native === undefined`
    end

    def method_missing (name, *args)
      return super unless Opal.function? `#@native[name]`

      __native_send__ name, *args
    end
  end

  def self.included (klass)
    class << klass
      def from_native (object)
        instance = allocate
        instance.instance_variable_set :@native, object

        instance
      end
    end
  end

  def initialize (native)
    @native = native
  end

  def to_native
    @native
  end

  def native_send (name, *args)
    return method_missing(name, *args) unless Opal.function? `#@native[name]`

    `#@native[name].apply(#@native, args)`
  end

  alias_method :__native_send__, :native_send
end
