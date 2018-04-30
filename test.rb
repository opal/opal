module ModuleSpecs

  class Parent
  end

  module Basic
  end

  module Super
    include Basic
  end

  class Child < Parent
    include Super
  end
end

p BasicObject.ancestors
p [BasicObject]

p ModuleSpecs.ancestors
p [ModuleSpecs]

p ModuleSpecs::Basic.ancestors
p [ModuleSpecs::Basic]

p ModuleSpecs::Super.ancestors
p [ModuleSpecs::Super, ModuleSpecs::Basic]


p ModuleSpecs::Parent.ancestors
p [ModuleSpecs::Parent, Object, Kernel, BasicObject]

p ModuleSpecs::Child.ancestors
p [ModuleSpecs::Child, ModuleSpecs::Super, ModuleSpecs::Basic, ModuleSpecs::Parent, Object, Kernel, BasicObject]

obj = Object.new
p obj.singleton_class.ancestors
p [obj.singleton_class, Object, Kernel, BasicObject]

module M
end
p M.singleton_class.ancestors
p [M.singleton_class, Module, Object, Kernel, BasicObject]

begin
  p Math.lgamma(-Float::INFINITY)
rescue Math::DomainError
  p 'caught'
end
