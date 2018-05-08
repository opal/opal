class K
  def example_instance_method
  end
  def self.example_class_method
  end
end

class Class
  def example_instance_method_of_class; end
  def self.example_class_method_of_class; end
end
class << Class
  def example_instance_method_of_singleton_class; end
  def self.example_class_method_of_singleton_class; end
end
class Object
  def example_instance_method_of_object; end
  def self.example_class_method_of_object; end
end

k = K.new
k_sc = k.singleton_class

p k_sc.ancestors
p [k_sc, K, Object, Kernel, BasicObject]

if RUBY_ENGINE == 'opal'
  `debugger`
  p `Opal.methods(k_sc)`.grep(/example/)
else
  require 'pry'; binding.pry
  p k_sc.methods.grep(/example/)
end

p [:example_class_method, :example_class_method_of_object, :example_instance_method_of_class, :example_instance_method_of_object]

p [:example_class_method, k_sc.example_class_method]
p [:example_class_method_of_object, k_sc.example_class_method_of_object]
p [:example_instance_method_of_class, k_sc.example_instance_method_of_class]
p [:example_instance_method_of_object, k_sc.example_instance_method_of_object]
