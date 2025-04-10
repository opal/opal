# NOTE: run bin/format-filters after changing this file
opal_filter "Proc" do
  fails "Proc#arity for instances created with proc { || } returns positive values for definition \n    @a = proc { |(a, (*b, c)), d=1| }\n          @b = proc { |a, (*b, c), d, (*e), (*), **k| }" # Expected -2  == 1  to be truthy but was false
  fails "Proc#arity for instances created with proc { || } returns positive values for definition \n    @a = proc { |a, b=1| }\n          @b = proc { |a, b, c=1, d=2| }" # Expected -2  == 1  to be truthy but was false
  fails "Proc#arity for instances created with proc { || } returns zero for definition \n    @a = proc { |**k, &l| }\n          @b = proc { |a: 1, b: 2, **k| }" # Expected -1  == 0  to be truthy but was false
  fails "Proc#arity for instances created with proc { || } returns zero for definition \n    @a = proc { |a: 1| }\n          @b = proc { |a: 1, b: 2| }" # Expected -1  == 0  to be truthy but was false
  fails "Proc#arity for instances created with proc { || } returns zero for definition \n    @a = proc { |a=1, b: 2| }\n          @b = proc { |a=1, b: 2| }" # Expected -1  == 0  to be truthy but was false
  fails "Proc#arity for instances created with proc { || } returns zero for definition \n    @a = proc { |a=1| }\n          @b = proc { |a=1, b=2| }" # Expected -1  == 0  to be truthy but was false
end
