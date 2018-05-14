module M1; end
module M2; end
module M3; end
module M4; end

class A
  include M1
  # prepend M2
end

class B < A
  include M3
  # prepend M4
end

p A.included_modules
p B.included_modules

# `debugger`

123
