module M
  def test_method; 1; end
end

class A
  include M
  def test_method; 2; end
end

class B < A
  undef :test_method
end

p B.new.methods.grep(/test_method/)

class A
  def test_method; end
end

p B.new.methods.grep(/test_method/)


p Module.public_instance_methods(false).grep(/attr/)
