class A
  def a
    p 'A'
  end
end

module M1
  def a
    p 'M1'
    super
  end
end

module M2
  def a
    p 'M2'
    super
  end
end

class B < A
  include M1
  include M2

  def a
    p 'B'
    super
  end
end

b = B.new
b.a

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

