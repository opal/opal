opal_filter "precedence" do
  fails "Operators or/and have higher precedence than if unless while until modifiers"
  fails "Operators = %= /= -= += |= &= >>= <<= *= &&= ||= **= have higher precedence than defined? operator"
  fails "Operators = %= /= -= += |= &= >>= <<= *= &&= ||= **= are right-associative"
  fails "Operators rescue has higher precedence than ="
  fails "Operators ? : has higher precedence than rescue"
  fails "Operators + - have higher precedence than >> <<"
  fails "Operators + - are left-associative"
  fails "Operators * / % are left-associative"
end
