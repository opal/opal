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

      `#@native[name].apply(self, args)`
    end
  end

  def initialize (native)
    @native = native
  end

  def to_native
    @native
  end
end

module Kernel
  def Native (object)
    Native::Object.new(object)
  end
end
