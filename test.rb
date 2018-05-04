module M
end

class A
end

class B < A
end

include M

p A.ancestors
p [A, Object, M, Kernel, BasicObject]

p B.ancestors
p [B, A, Object, M, Kernel, BasicObject]
