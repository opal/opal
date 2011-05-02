module Private
  class A
    def foo
      "foo"
    end

    private
    def bar
      "bar"
    end
  end

  class B
    def foo
      "foo"
    end

    private
    class C
      def baz
        "baz"
      end
    end

    class << self
      def public_class_method1; 1; end
      private
      def private_class_method1; 1; end
    end
    def self.public_class_method2; 2; end

    def bar
      "bar"
    end
  end

  class F
    def foo
      "foo"
    end
  end
end


