module Super
  module S1
    class A
      def foo(a)
        a << "A#foo"
        bar(a)
      end
      def bar(a)
        a << "A#bar"
      end
    end
    class B < A
      def foo(a)
        a << "B#foo"
        super(a)
      end
      def bar(a)
        a << "B#bar"
        super(a)
      end
    end
  end

  module S2
    class A
      def baz(a)
        a << "A#baz"
      end
    end
    class B < A
      def foo(a)
        a << "B#foo"
        baz(a)
      end
    end
    class C < B
      def baz(a)
        a << "C#baz"
        super(a)
      end
    end
  end

  module S3
    class A
      def foo(a)
        a << "A#foo"
      end
      def self.foo(a)
        a << "A::foo"
      end
      def self.bar(a)
        a << "A::bar"
        foo(a)
      end
    end
    class B < A
      def self.foo(a)
        a << "B::foo"
        super(a)
      end
      def self.bar(a)
        a << "B::bar"
        super(a)
      end
    end
  end

  class S5
    def here
      :good
    end
  end

  class S6 < S5
    def under
      yield
    end

    def here
      under {
        super
      }
    end
  end

  class S7 < S5
    define_method(:here) { super() }
  end
end
