describe "The super keyword" do
  it "calls the method on the calling class" do
    Super::S1::A.new.foo([]).should == ["A#foo", "A#bar"]
    Super::S1::A.new.bar([]).should == ["A#bar"]
    Super::S1::B.new.foo([]).should == ["B#foo", "A#foo", "B#bar", "A#bar"]
    Super::S1::B.new.bar([]).should == ["B#bar", "A#bar"]
  end

  it "searches the full inheritence chain" do
    Super::S2::B.new.foo([]).should == ["B#foo", "A#baz"]
    Super::S2::B.new.baz([]).should == ["A#baz"]
    Super::S2::C.new.foo([]).should == ["B#foo", "C#baz", "A#baz"]
    Super::S2::C.new.baz([]).should == ["C#baz", "A#baz"]
  end

  it "searches class methods" do
    Super::S3::A.new.foo([]).should == ["A#foo"]
    Super::S3::A.foo([]).should == ["A::foo"]
    Super::S3::A.bar([]).should == ["A::bar", "A::foo"]
    Super::S3::B.new.foo([]).should == ["A#foo"]
    Super::S3::B.foo([]).should == ["B::foo", "A::foo"]
    Super::S3::B.bar([]).should == ["B::bar", "A::bar", "B::foo", "A::foo"]
  end

  it "calls the method on the calling class including modules" do
    Super::MS1::A.new.foo([]).should == ["ModA#foo", "ModA#bar"]
    Super::MS1::A.new.bar([]).should == ["ModA#bar"]
    Super::MS1::B.new.foo([]).should == ["B#foo","ModA#foo","ModB#bar","ModA#bar"]
    Super::MS1::B.new.bar([]).should == ["ModB#bar", "ModA#bar"]
  end

  it "searches the full inheritence chain including modules" do
    Super::MS2::B.new.foo([]).should == ["ModB#foo", "A#baz"]
    Super::MS2::B.new.baz([]).should == ["A#baz"]
    Super::MS2::C.new.baz([]).should == ["C#baz", "A#baz"]
    Super::MS2::C.new.foo([]).should == ["ModB#foo","C#baz","A#baz"]
  end

  it "calls the superclass method when in a block" do
    Super::S6.new.here.should == :good
  end

  it "calls the superclass when initial method is define_method'd" do
    Super::S7.new.here.should == :good
  end
end

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

  module MS2
    class A
      def baz(a)
        a << "A#baz"
      end
    end
    module ModB
      def foo(a)
        a << "ModB#foo"
        baz(a)
      end
    end
    class B < A
      include ModB
    end
    class C < B
      def baz(a)
        a << "C#baz"
        super(a)
      end
    end
  end
end