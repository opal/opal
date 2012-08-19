module YieldSpecs
  class Yielder
    def z
      yield
    end

    def s(a)
      yield(a)
    end

    def m(a, b, c)
      yield(a, b, c)
    end

    def r(a)
      yield(*a)
    end

    def rs(a, b, c)
      yield(a, b, *c)
    end
  end
end