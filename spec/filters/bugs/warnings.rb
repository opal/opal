# NOTE: run bin/format-filters after changing this file
opal_filter "warnings" do
  fails "Array#join when $, is not nil warns" # Expected warning to match: /warning: \$, is set to non-nil value/ but got: ""
  fails "Constant resolution within methods with dynamically assigned constants returns the updated value when a constant is reassigned" # Expected warning to match: /already initialized constant/
  fails "Fixnum is deprecated" # Expected warning to match: /constant ::Fixnum is deprecated/ but got: ""
  fails "Hash#fetch gives precedence to the default block over the default argument when passed both" # Expected warning to match: /block supersedes default value argument/
  fails "Hash.[] ignores elements that are not arrays" # Expected warning to match: /ignoring wrong elements/
  fails "Integer#** bignum switch to a Float when the values is too big" # Expected warning to match: /warning: in a\*\*b, b may be too big/ but got: ""
  fails "Integer#** fixnum returns Float::INFINITY when the number is too big" # Expected warning to match: /warning: in a\*\*b, b may be too big/ but got: ""
  fails "Integer#pow one argument is passed fixnum returns Float::INFINITY when the number is too big" # Expected warning to match: /warning: in a\*\*b, b may be too big/ but got: ""
  fails "Kernel#=~ is deprecated" # Expected warning to match: /deprecated Object#=~ is called on Object/ but got: ""
  fails "Literal (A::X) constant resolution with dynamically assigned constants returns the updated value when a constant is reassigned" # Expected warning to match: /already initialized constant/
  fails "Literal Regexps matches against $_ (last input) in a conditional if no explicit matchee provided" # Expected warning to match: /regex literal in condition/
  fails "Module#const_get with dynamically assigned constants returns the updated value of a constant" # Expected warning to match: /already initialized constant/
  fails "Optional variable assignments using compunded constants with &&= assignments" # Expected warning to match: /already initialized constant/
  fails "Optional variable assignments using compunded constants with operator assignments" # Expected warning to match: /already initialized constant/
  fails "Predefined global $, warns if assigned non-nil" # Expected warning to match: /warning: `\$,' is deprecated/ but got: ""
  fails "Predefined global $; warns if assigned non-nil" # Expected warning to match: /warning: `\$;' is deprecated/ but got: ""
  fails "Regexp.new given a Regexp does not honour options given as additional arguments" # Expected warning to match: /flags ignored/
  fails "String#split with String when $; is not nil warns" # Expected warning to match: /warning: \$; is set to non-nil value/ but got: ""
  fails "Struct.new overwrites previously defined constants with string as first argument" # Expected warning to match: /redefining constant/
  fails "The defined? keyword for a variable scoped constant returns 'constant' if the constant is defined in the scope of the class variable" # Expected warning to match: /class variable access from toplevel/
  fails "The defined? keyword for a variable scoped constant returns nil if the class scoped constant is not defined" # Expected warning to match: /class variable access from toplevel/
  fails "The defined? keyword for an expression with logical connectives returns nil for an expression with '!' and an unset class variable" # Expected warning to match: /class variable access from toplevel/
  fails "The defined? keyword for an expression with logical connectives returns nil for an expression with 'not' and an unset class variable" # Expected warning to match: /class variable access from toplevel/
  fails "The for expression allows a constant as an iterator name" # Expected warning to match: /already initialized constant/
  fails "The predefined global constants includes FALSE" # Expected warning to match: /constant ::FALSE is deprecated/
  fails "The predefined global constants includes NIL" # Expected warning to match: /constant ::NIL is deprecated/
  fails "The predefined global constants includes TRUE" # Expected warning to match: /constant ::TRUE is deprecated/
end
