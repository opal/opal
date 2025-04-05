# backtick_javascript: true

class ObjectSpecifier
  class << self
    def classOf(arg)
      `ObjectSpecifier.classOf(arg)`
    end

    def method_missing(name, *args)
      name_s = name.to_s
      if args.size == 0
        `ObjectSpecifier[name_s]`
      else
        `ObjectSpecifier[name_s](...args)`
      end
    end
  end
end
