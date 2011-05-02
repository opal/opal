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
  
  module S4
    class A
      def foo(a)
        a << "A#foo"
      end
    end
    class B < A
      def foo(a, b)
        a << "B#foo(a,#{b})"
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

  module MS1
    module ModA
      def foo(a)
        a << "ModA#foo"
        bar(a)
      end      
      def bar(a)
        a << "ModA#bar"
      end
    end
    class A
      include ModA
    end
    module ModB
      def bar(a)
        a << "ModB#bar"
        super(a)
      end
    end
    class B < A    
      def foo(a)
        a << "B#foo"
        super(a)
      end
      include ModB
    end
  end
  # 
  # module MS2
  #   class A
  #     def baz(a)
  #       a << "A#baz"
  #     end
  #   end
  #   module ModB
  #     def foo(a)
  #       a << "ModB#foo"
  #       baz(a)
  #     end
  #   end
  #   class B < A
  #     include ModB
  #   end
  #   class C < B
  #     def baz(a)
  #       a << "C#baz"
  #       super(a)
  #     end
  #   end
  # end
  # 
  # module MS3
  #   module ModA
  #     def foo(a)
  #       a << "ModA#foo"
  #     end
  #     def bar(a)
  #       a << "ModA#bar"
  #       foo(a)
  #     end
  #   end
  #   class A
  #     def foo(a)
  #       a << "A#foo"
  #     end
  #     class << self
  #       include ModA
  #     end
  #   end
  #   class B < A
  #     def self.foo(a)
  #       a << "B::foo"
  #       super(a)
  #     end
  #     def self.bar(a)
  #       a << "B::bar"
  #       super(a)
  #     end
  #   end
  # end  
  # 
  # module MS4
  #   module Layer1
  #     def example
  #       5
  #     end
  #   end
  # 
  #   module Layer2
  #     include Layer1
  #     def example
  #       super
  #     end
  #   end
  # 
  #   class A
  #     include Layer2
  #     public :example
  #   end
  # end

  # class MM_A
  #    undef_method :is_a?
  #  end
  # 
  #  class MM_B < MM_A
  #    def is_a?(blah)
  #      # should fire the method_missing below
  #      super
  #    end
  # 
  #    def method_missing(*)
  #      false
  #    end
  #  end
  # 
  #  class Alias1
  #    def name
  #      [:alias1]
  #    end
  #  end
  # 
  #  class Alias2 < Alias1
  #    def initialize
  #      @times = 0
  #    end
  # 
  #    def name
  #      if @times >= 10
  #        raise "runaway super"
  #      end
  # 
  #      @times += 1
  # 
  #      # Use this so that we can see collect all supers that we see.
  #      # One bug that arises is that we call Alias2#name from Alias2#name
  #      # as it's superclass. In that case, either we get a runaway recursion
  #      # super OR we get the return value being [:alias2, :alias2, :alias1]
  #      # rather than [:alias2, :alias1].
  #      #
  #      # Which one depends on caches and how super is implemented.
  #      [:alias2] + super
  #    end
  #  end
  # 
  #  class Alias3 < Alias2
  #    alias_method :name3, :name
  #    # In the method table for Alias3 now should be a special alias entry
  #    # that references Alias2 and Alias2#name (probably as an object).
  #    #
  #    # When name3 is called then, Alias2 (NOT Alias3) is presented as the
  #    # current module to Alias2#name, so that when super is called,
  #    # Alias2->superclass is next.
  #    #
  #    # Otherwise, Alias2 is next, which is where name was to begin with,
  #    # causing the wrong #name method to be called.
  #  end
  # 
  #  module AliasWithSuper
  #    module AS1
  #      def foo
  #        :a
  #      end
  #    end
  # 
  #    module BS1
  #      def foo
  #        [:b, super]
  #      end
  #    end
  # 
  #    class Base
  #      extend AS1
  #      extend BS1
  #    end
  # 
  #    class Trigger < Base
  #      class << self
  #        def foo_quux
  #          foo_baz
  #        end
  # 
  #        alias_method :foo_baz, :foo
  #        alias_method :foo, :foo_quux
  #      end
  #    end
  #  end
  
end
