class A
  def a1; end
end

module M
  def m1; end
end

class B < A
  include M
  def b1; end
end

class A
  def a2; end
end

class B
  def b2; end
end

module M
  def m2; end
end

b = B.new
`debugger`

b.a1
b.a2
b.b1
b.b2
b.m1
b.m2


123

# %x{
#   function printMap(mod) {
#     if (mod.hasOwnProperty('$$is_singleton')) {
#       console.log(`singleton<${mod.$$singleton_of.$$name}>`);
#     } else {
#       console.log(mod.$$name);
#     }

#     mod.$$children.forEach(mod => printMap(mod))
#   }

#   printMap(Opal.BasicObject);
# }

# p 42

# 123

