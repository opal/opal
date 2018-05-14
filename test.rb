module M
  A = 1
end

module N
  A = 2
end

class K; end

K.include M
p K::A
p 1
K.include N
p K::A
p 2
