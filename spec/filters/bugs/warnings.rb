opal_filter "warnings" do
  fails "Constant resolution within methods with dynamically assigned constants returns the updated value when a constant is reassigned" # Expected warning to match: /already initialized constant/
  fails "Literal (A::X) constant resolution with dynamically assigned constants returns the updated value when a constant is reassigned" # Expected warning to match: /already initialized constant/
  fails "The defined? keyword for a variable scoped constant returns 'constant' if the constant is defined in the scope of the class variable" # Expected warning to match: /class variable access from toplevel/
  fails "The defined? keyword for a variable scoped constant returns nil if the class scoped constant is not defined" # Expected warning to match: /class variable access from toplevel/
  fails "The defined? keyword for an expression with logical connectives returns nil for an expression with '!' and an unset class variable" # Expected warning to match: /class variable access from toplevel/
  fails "The defined? keyword for an expression with logical connectives returns nil for an expression with 'not' and an unset class variable" # Expected warning to match: /class variable access from toplevel/
  fails "The for expression allows a constant as an iterator name" # Expected warning to match: /already initialized constant/
  fails "Literal Regexps matches against $_ (last input) in a conditional if no explicit matchee provided" # Expected warning to match: /regex literal in condition/
  fails "Optional variable assignments using compunded constants with &&= assignments" # Expected warning to match: /already initialized constant/
  fails "Optional variable assignments using compunded constants with operator assignments" # Expected warning to match: /already initialized constant/
  fails "The predefined global constants includes FALSE" # Expected warning to match: /constant ::FALSE is deprecated/
  fails "The predefined global constants includes NIL" # Expected warning to match: /constant ::NIL is deprecated/
  fails "The predefined global constants includes TRUE" # Expected warning to match: /constant ::TRUE is deprecated/
  fails "Hash#fetch gives precedence to the default block over the default argument when passed both" # Expected warning to match: /block supersedes default value argument/
  fails "Hash.[] ignores elements that are not arrays" # Expected warning to match: /ignoring wrong elements/
  fails "Module#attr with a boolean argument emits a warning when $VERBOSE is true" # Expected warning to match: /boolean argument is obsoleted/
  fails "Module#const_get with dynamically assigned constants returns the updated value of a constant" # Expected warning to match: /already initialized constant/
  fails "Regexp.new given a Regexp does not honour options given as additional arguments" # Expected warning to match: /flags ignored/
  fails "Regexp.new given a Regexp does not honour options given as additional arguments" # Expected warning to match: /flags ignored/
  fails "Struct.new overwrites previously defined constants with string as first argument" # Expected warning to match: /redefining constant/
  fails "Time#succ returns a new instance" # Expected warning to match: /Time#succ is obsolete/
  fails "Time#succ returns a new time one second later than time" # Expected warning to match: /Time#succ is obsolete/
end
