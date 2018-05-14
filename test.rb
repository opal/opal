module Root
  module M1; end
  module M2; end
  module M3; include M2; end

  module M2; include M1; end

  module M3; include M2; end # 2nd include
end

p Root::M3.ancestors
p [Root::M3, Root::M2, Root::M1]

# module A; end
# module B; end
# module C; end

# A.include(C)
# B.include(C)

# class D; include A; end

# p D.ancestors

# D.include B

# p D.ancestors
