# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Kernel" do
  fails "Kernel#Float raises a TypeError if #to_f returns an Integer" # Expected TypeError but no exception was raised (123 was returned)
  fails "Kernel#class returns the first non-singleton class" # TypeError: can't define singleton
  fails "Kernel#initialize_dup returns the receiver" # Expected nil == #<Object:0x6a424> to be truthy but was false
  fails "Kernel#sleep accepts a Rational" # TypeError: can't convert Rational into time interval
  fails "Kernel#sleep pauses execution indefinitely if not given a duration" # NotImplementedError: Thread creation not available
  fails "Kernel#warn calls Warning.warn with category: nil if Warning.warn accepts keyword arguments" # NameError: uninitialized constant Warning
  fails "Kernel#warn calls Warning.warn with given category keyword converted to a symbol" # NameError: uninitialized constant Warning
  fails "Kernel#warn calls Warning.warn without keyword arguments if Warning.warn does not accept keyword arguments" # NameError: uninitialized constant Warning
  fails "Kernel#warn is a private method" # Expected Kernel to have private instance method 'warn' but it does not
  fails "Kernel.Float raises a TypeError if #to_f returns an Integer" # Expected TypeError but no exception was raised (123 was returned)
  fails "Kernel.lambda when called without a literal block warns when proc isn't a lambda" # Expected warning: "ruby/core/kernel/lambda_spec.rb:142: warning: lambda without a literal block is deprecated; use the proc without lambda instead\n" but got: ""
  fails "Kernel.printf formatting io is specified other formats s formats nil with width and precision" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified other formats s formats string with width and precision" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified other formats s formats string with width" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified other formats s substitutes '' for nil" # Exception: format_string.indexOf is not a function  
end
