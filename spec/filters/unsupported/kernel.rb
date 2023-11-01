# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Kernel" do
  fails "Kernel has private instance method Array()" # Expected Kernel to have private instance method 'Array' but it does not
  fails "Kernel has private instance method Hash()" # Expected Kernel to have private instance method 'Hash' but it does not
  fails "Kernel#Float is a private method" # Expected Kernel to have private instance method 'Float' but it does not
  fails "Kernel#Float raises a TypeError if #to_f returns an Integer" # Expected TypeError but no exception was raised (123 was returned)
  fails "Kernel#Integer is a private method" # Expected Kernel to have private instance method 'Integer' but it does not
  fails "Kernel#String is a private method" # Expected Kernel to have private instance method 'String' but it does not
  fails "Kernel#class returns the first non-singleton class" # TypeError: can't define singleton
  fails "Kernel#eql? is a public instance method" # Expected Kernel to have public instance method 'eql?' but it does not
  fails "Kernel#fail is a private method" # Expected Kernel to have private instance method 'fail' but it does not
  fails "Kernel#format is a private method" # Expected Kernel to have private instance method 'format' but it does not
  fails "Kernel#initialize_dup returns the receiver" # Expected nil == #<Object:0x6a424> to be truthy but was false
  fails "Kernel#raise is a private method" # Expected Kernel to have private instance method 'raise' but it does not
  fails "Kernel#sleep accepts a Rational" # TypeError: can't convert Rational into time interval
  fails "Kernel#sleep is a private method" # Expected Kernel to have private instance method 'sleep' but it does not
  fails "Kernel#sleep pauses execution indefinitely if not given a duration" # NotImplementedError: Thread creation not available
  fails "Kernel#warn calls Warning.warn with category: nil if Warning.warn accepts keyword arguments" # NameError: uninitialized constant Warning
  fails "Kernel#warn calls Warning.warn with given category keyword converted to a symbol" # NameError: uninitialized constant Warning
  fails "Kernel#warn calls Warning.warn without keyword arguments if Warning.warn does not accept keyword arguments" # NameError: uninitialized constant Warning
  fails "Kernel#warn is a private method" # Expected Kernel to have private instance method 'warn' but it does not
  fails "Kernel.Float raises a TypeError if #to_f returns an Integer" # Expected TypeError but no exception was raised (123 was returned)
  fails "Kernel.lambda when called without a literal block warns when proc isn't a lambda" # Expected warning: "ruby/core/kernel/lambda_spec.rb:142: warning: lambda without a literal block is deprecated; use the proc without lambda instead\n" but got: ""
end
