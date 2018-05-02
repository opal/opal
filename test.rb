class Parent
  def test_parent; end
end

class Child < Parent
  def test_child; end
end

module M1
  def test_m1; end
end

module M2
  def test_m2; end
end

`window.DEBUG = true`

Parent.include M1
Child.include M2

p Parent.instance_methods.grep(/\Atest_/)
p Child.instance_methods.grep(/\Atest_/)
p M1.instance_methods.grep(/\Atest_/)
p M2.instance_methods.grep(/\Atest_/)
