module BlockSpecs
  class Yielder
    def z
      yield
    end

    def m(*a)
      yield(*a)
    end

    def s(a)
      yield(a)
    end

    def r(a)
      yield(*a)
    end
  end
end
