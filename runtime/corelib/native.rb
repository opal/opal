module Native
  class Object
    include Native

    def [] (name)
      `#@native[name]`
    end

    def []= (name, value)
      `#@native[name] = value`
    end

    def method_missing (name, *args)
      return super unless Opal.function? `#@native[name]`

      __native_send__ name, *args
    end
  end

  def initialize (native)
    @native = native
  end

  def to_native
    @native
  end

  def native_send (name, *args)
    `#@native[name].apply(#@native, args)`
  end

  alias_method :__native_send__, :native_send
end

module Kernel
  def Native (object)
    Native::Object.new(object)
  end
end
