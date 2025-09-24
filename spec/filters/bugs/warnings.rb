# NOTE: run bin/format-filters after changing this file
opal_filter "warnings" do
  fails "Array#join when $, is not nil warns" # Expected warning to match: /warning: \$, is set to non-nil value/ but got: ""
  fails "Constant resolution within methods with dynamically assigned constants returns the updated value when a constant is reassigned" # Expected warning to match: /already initialized constant/ but got: ""
  fails "Hash#fetch gives precedence to the default block over the default argument when passed both" # Expected warning to match: /block supersedes default value argument/ but got: ""
  fails "Literal (A::X) constant resolution with dynamically assigned constants returns the updated value when a constant is reassigned" # Expected warning to match: /already initialized constant/ but got: ""
  fails "Literal Regexps matches against $_ (last input) in a conditional if no explicit matchee provided" # Expected warning to match: /regex literal in condition/ but got: ""
  fails "Module#const_get with dynamically assigned constants returns the updated value of a constant" # Expected warning to match: /already initialized constant/ but got: ""
  fails "Pattern matching warning when one-line form does not warn about pattern matching is experimental feature" # NameError: uninitialized constant Warning
  fails "Predefined global $, warns if assigned non-nil" # Expected warning to match: /warning: `\$,' is deprecated/ but got: ""
  fails "Predefined global $; warns if assigned non-nil" # Expected warning to match: /warning: `\$;' is deprecated/ but got: ""
  fails "Regexp.new given a Regexp does not honour options given as additional arguments" # Expected warning to match: /flags ignored/ but got: ""
  fails "Struct.new overwrites previously defined constants with string as first argument" # Expected warning to match: /constant/ but got: ""
  fails "The for expression allows a constant as an iterator name" # Expected warning to match: /already initialized constant/ but got: ""
end
