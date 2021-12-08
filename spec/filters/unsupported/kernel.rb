# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Kernel" do
  fails "Kernel has private instance method Array()"
  fails "Kernel has private instance method Hash()"
  fails "Kernel#Float is a private method"
  fails "Kernel#Float raises a TypeError if #to_f returns an Integer"
  fails "Kernel#Integer calls to_i on Rationals"
  fails "Kernel#Integer is a private method"
  fails "Kernel#Integer returns a Fixnum or Bignum object"
  fails "Kernel#String is a private method"
  fails "Kernel#class returns the first non-singleton class" # TypeError: can't define singleton
  fails "Kernel#clone preserves tainted state from the original"
  fails "Kernel#clone preserves untrusted state from the original"
  fails "Kernel#clone raises a TypeError for Symbol"
  fails "Kernel#dup does not copy frozen state from the original"
  fails "Kernel#dup preserves tainted state from the original"
  fails "Kernel#dup preserves untrusted state from the original"
  fails "Kernel#dup raises a TypeError for Symbol"
  fails "Kernel#eql? is a public instance method"
  fails "Kernel#fail is a private method"
  fails "Kernel#format is a private method"
  fails "Kernel#initialize_clone returns the receiver" # Expected nil == #<Object:0x63440> to be truthy but was false
  fails "Kernel#initialize_dup returns the receiver" # Expected nil == #<Object:0x4c314> to be truthy but was false
  fails "Kernel#inspect returns an untrusted string if self is untrusted"
  fails "Kernel#raise is a private method"
  fails "Kernel#sleep accepts a Rational"
  fails "Kernel#sleep is a private method"
  fails "Kernel#sleep pauses execution indefinitely if not given a duration"
  fails "Kernel#sprintf is a private method"
  fails "Kernel#to_s returns a tainted result if self is tainted"
  fails "Kernel#to_s returns an untrusted result if self is untrusted"
  fails "Kernel#warn calls Warning.warn with category: nil if Warning.warn accepts keyword arguments" # NameError: uninitialized constant Warning
  fails "Kernel#warn calls Warning.warn with given category keyword converted to a symbol" # NameError: uninitialized constant Warning
  fails "Kernel#warn calls Warning.warn without keyword arguments if Warning.warn does not accept keyword arguments" # NameError: uninitialized constant Warning
  fails "Kernel#warn is a private method"
  fails "Kernel.Float raises a TypeError if #to_f returns an Integer"
  fails "Kernel.Integer calls to_i on Rationals"
  fails "Kernel.Integer returns a Fixnum or Bignum object"
  fails "Kernel.fail is a private method"
  fails "Kernel.lambda when called without a literal block warns when proc isn't a lambda" # Expected warning: "ruby/core/kernel/lambda_spec.rb:142: warning: lambda without a literal block is deprecated; use the proc without lambda instead\n" but got: ""
  fails "Kernel.printf formatting io is specified other formats s formats nil with width and precision" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified other formats s formats nli with precision" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified other formats s formats nli with width" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified other formats s formats string with width and precision" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified other formats s formats string with width" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified other formats s substitutes '' for nil" # Exception: format_string.indexOf is not a function
end
