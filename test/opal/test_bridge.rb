# backtick_javascript: true
require 'test/unit'

class TestBridge < Test::Unit::TestCase
  %x{
    class MyClass {
      constructor(a, b, c) {
        this.a = a;
        this.b = b;
        this.c = c;
      }
      geta() { return this.a; }
      get bget() { return this.b; }
      set bset(v) { return this.b = v; }
    }
  }

  class MyClass < `MyClass`
    def geta
      `self.geta()`
    end

    def b
      `self.bget`
    end

    def b=(v)
      `self.b = v`
    end

    def c
      `self.c`
    end
  end

  def test_bridge_custom_class
    i = MyClass.new(1,2,3)

    assert_equal(1, i.geta)
    assert_equal(2, i.b)
    assert_equal(3, i.c)

    i.b = 4
    assert_equal(4, i.b)
  end
end