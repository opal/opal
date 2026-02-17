# NOTE: run bin/format-filters after changing this file
opal_filter "Proc" do
  fails "Proc#<< composition is a lambda when parameter is lambda" # Expected #<Proc:0x58f9a>.lambda? to be truthy but was false
  fails "Proc#<< does not try to coerce argument with #to_proc" # Expected TypeError (callable object is expected) but no exception was raised (#<Proc:0x58f4c> was returned)
  fails "Proc#<< raises TypeError if passed not callable object" # Expected TypeError (callable object is expected) but no exception was raised (#<Proc:0x58f74> was returned)
  fails "Proc#== is a public method" # Expected Proc to have public instance method '==' but it does not
  fails "Proc#== returns true if other is a dup of the original" # Expected false to be true
  fails "Proc#=== can call its block argument declared with a block argument" # Expected 6 == 10 to be truthy but was false
  fails "Proc#=== on a Proc created with Kernel#lambda or Kernel#proc ignores excess arguments when self is a proc" # ArgumentError: expected kwargs
  fails "Proc#=== yields to the block given at declaration and not to the block argument" # Expected 3 == 7 to be truthy but was false
  fails "Proc#>> composition is a lambda when self is lambda" # Expected #<Proc:0x5903a>.lambda? to be truthy but was false
  fails "Proc#>> does not try to coerce argument with #to_proc" # Expected TypeError (callable object is expected) but no exception was raised (#<Proc:0x58fe8> was returned)
  fails "Proc#>> raises TypeError if passed not callable object" # Expected TypeError (callable object is expected) but no exception was raised (#<Proc:0x59010> was returned)
  fails "Proc#[] can call its block argument declared with a block argument" # Expected 6 == 10 to be truthy but was false
  fails "Proc#[] with frozen_string_literals doesn't duplicate frozen strings" # Expected true to be false
  fails "Proc#[] yields to the block given at declaration and not to the block argument" # Expected 3 == 7 to be truthy but was false
  fails "Proc#arity for instances created with proc { || } returns positive values for definition \n    @a = proc { |(a, (*b, c)), d=1| }\n    @b = proc { |a, (*b, c), d, (*e), (*), **k| }" # Expected -2 == 1 to be truthy but was false
  fails "Proc#arity for instances created with proc { || } returns positive values for definition \n    @a = proc { |a, b=1| }\n    @b = proc { |a, b, c=1, d=2| }" # Expected -2 == 1 to be truthy but was false
  fails "Proc#arity for instances created with proc { || } returns zero for definition \n    @a = proc { |**k, &l| }\n    @b = proc { |a: 1, b: 2, **k| }" # Expected -1 == 0 to be truthy but was false
  fails "Proc#arity for instances created with proc { || } returns zero for definition \n    @a = proc { |a: 1| }\n    @b = proc { |a: 1, b: 2| }" # Expected -1 == 0 to be truthy but was false
  fails "Proc#arity for instances created with proc { || } returns zero for definition \n    @a = proc { |a=1, b: 2| }\n    @b = proc { |a=1, b: 2| }" # Expected -1 == 0 to be truthy but was false
  fails "Proc#arity for instances created with proc { || } returns zero for definition \n    @a = proc { |a=1| }\n    @b = proc { |a=1, b=2| }" # Expected -1 == 0 to be truthy but was false
  fails "Proc#binding returns the binding associated with self" # RuntimeError: Evaluation on a Proc#binding is not supported
  fails "Proc#call can call its block argument declared with a block argument" # Expected 6 == 10 to be truthy but was false
  fails "Proc#call on a Proc created with Kernel#lambda or Kernel#proc ignores excess arguments when self is a proc" # ArgumentError: expected kwargs
  fails "Proc#call yields to the block given at declaration and not to the block argument" # Expected 3 == 7 to be truthy but was false
  fails "Proc#clone returns an instance of subclass" # Expected Proc == #<Class:0x71d98> to be truthy but was false
  fails "Proc#curry with arity argument returns Procs with arities of -1 regardless of the value of _arity_" # ArgumentError: wrong number of arguments (3 for 1)
  fails "Proc#curry with arity argument returns a Proc if called on a lambda that requires fewer than _arity_ arguments but may take more" # ArgumentError: wrong number of arguments (4 for 5)
  fails "Proc#dup returns an instance of subclass" # Expected Proc == #<Class:0x8f364> to be truthy but was false
  fails "Proc#eql? is a public method" # Expected Proc to have public instance method 'eql?' but it does not
  fails "Proc#eql? returns true if other is a dup of the original" # Expected false to be true
  fails "Proc#inspect for a proc created with Proc.new has a binary encoding" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT> to be truthy but was false
  fails "Proc#inspect for a proc created with Proc.new returns a description including file and line number" # Expected "#<Proc:0x122d8>" =~ /^#<Proc:([^ ]*?) ruby\/core\/proc\/shared\/to_s\.rb:4>$/ to be truthy but was nil
  fails "Proc#inspect for a proc created with Symbol#to_proc has a binary encoding" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT> to be truthy but was false
  fails "Proc#inspect for a proc created with Symbol#to_proc returns a description including '(&:symbol)'" # Expected "#<Proc:0x12484>".include? "(&:foobar)" to be truthy but was false
  fails "Proc#inspect for a proc created with UnboundMethod#to_proc has a binary encoding" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT> to be truthy but was false
  fails "Proc#inspect for a proc created with UnboundMethod#to_proc returns a description including '(lambda)' and optionally including file and line number" # Expected "#<Proc:0x1241a>" =~ /^#<Proc:([^ ]*?) \(lambda\)>$/ to be truthy but was nil
  fails "Proc#inspect for a proc created with lambda has a binary encoding" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT> to be truthy but was false
  fails "Proc#inspect for a proc created with lambda returns a description including '(lambda)' and including file and line number" # Expected "#<Proc:0x12342>" =~ /^#<Proc:([^ ]*?) ruby\/core\/proc\/shared\/to_s\.rb:14 \(lambda\)>$/ to be truthy but was nil
  fails "Proc#inspect for a proc created with proc has a binary encoding" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT> to be truthy but was false
  fails "Proc#inspect for a proc created with proc returns a description including file and line number" # Expected "#<Proc:0x123ac>" =~ /^#<Proc:([^ ]*?) ruby\/core\/proc\/shared\/to_s\.rb:24>$/ to be truthy but was nil
  fails "Proc#lambda? is preserved when passing a Proc with & to the lambda keyword" # Expected true to be false
  fails "Proc#lambda? is preserved when passing a Proc with & to the proc keyword" # Expected false to be true
  fails "Proc#ruby2_keywords applies to the underlying method and applies across duplication" # Expected false == true to be truthy but was false
  fails "Proc#ruby2_keywords marks the final hash argument as keyword hash" # Expected false == true to be truthy but was false
  fails "Proc#ruby2_keywords prints warning when a proc accepts keyword splat" # Expected warning to match: /Skipping set of ruby2_keywords flag for/ but got: ""
  fails "Proc#ruby2_keywords prints warning when a proc accepts keywords" # Expected warning to match: /Skipping set of ruby2_keywords flag for/ but got: ""
  fails "Proc#ruby2_keywords prints warning when a proc does not accept argument splat" # Expected warning to match: /Skipping set of ruby2_keywords flag for/ but got: ""
  fails "Proc#source_location returns an Array" # Expected nil (NilClass) to be an instance of Array
  fails "Proc#source_location returns the same value for a proc-ified method as the method reports" # Expected ["ruby/core/proc/fixtures/source_location.rb", 3] == nil to be truthy but was false
  fails "Proc#source_location sets the first value to the path of the file in which the proc was defined" # Expected "ruby/core/proc/fixtures/source_location.rb" == "./ruby/core/proc/fixtures/source_location.rb" to be truthy but was false
  fails "Proc#source_location sets the last value to an Integer representing the line on which the proc was defined" # NoMethodError: undefined method `last' for nil
  fails "Proc#source_location works for eval with a given line" # Expected nil == ["foo", 100] to be truthy but was false
  fails "Proc#to_s for a proc created with Proc.new has a binary encoding" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT> to be truthy but was false
  fails "Proc#to_s for a proc created with Proc.new returns a description including file and line number" # Expected "#<Proc:0x5813e>" =~ /^#<Proc:([^ ]*?) ruby\/core\/proc\/shared\/to_s\.rb:4>$/ to be truthy but was nil
  fails "Proc#to_s for a proc created with Symbol#to_proc has a binary encoding" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT> to be truthy but was false
  fails "Proc#to_s for a proc created with Symbol#to_proc returns a description including '(&:symbol)'" # Expected "#<Proc:0x582ea>".include? "(&:foobar)" to be truthy but was false
  fails "Proc#to_s for a proc created with UnboundMethod#to_proc has a binary encoding" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT> to be truthy but was false
  fails "Proc#to_s for a proc created with UnboundMethod#to_proc returns a description including '(lambda)' and optionally including file and line number" # Expected "#<Proc:0x58280>" =~ /^#<Proc:([^ ]*?) \(lambda\)>$/ to be truthy but was nil
  fails "Proc#to_s for a proc created with lambda has a binary encoding" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT> to be truthy but was false
  fails "Proc#to_s for a proc created with lambda returns a description including '(lambda)' and including file and line number" # Expected "#<Proc:0x581a8>" =~ /^#<Proc:([^ ]*?) ruby\/core\/proc\/shared\/to_s\.rb:14 \(lambda\)>$/ to be truthy but was nil
  fails "Proc#to_s for a proc created with proc has a binary encoding" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT> to be truthy but was false
  fails "Proc#to_s for a proc created with proc returns a description including file and line number" # Expected "#<Proc:0x58212>" =~ /^#<Proc:([^ ]*?) ruby\/core\/proc\/shared\/to_s\.rb:24>$/ to be truthy but was nil
  fails "Proc#yield can call its block argument declared with a block argument" # Expected 6 == 10 to be truthy but was false
  fails "Proc#yield on a Proc created with Kernel#lambda or Kernel#proc ignores excess arguments when self is a proc" # ArgumentError: expected kwargs
  fails "Proc#yield yields to the block given at declaration and not to the block argument" # Expected 3 == 7 to be truthy but was false
  fails "Proc.allocate raises a TypeError" # Expected TypeError but no exception was raised (#<Proc:0x38dee> was returned)
  fails "Proc.new with a block argument called indirectly from a subclass returns the passed proc created from a block" # Expected Proc == ProcSpecs::MyProc to be truthy but was false
  fails "Proc.new with a block argument called indirectly from a subclass returns the passed proc created from a method" # Expected Proc == ProcSpecs::MyProc to be truthy but was false
  fails "Proc.new with a block argument called indirectly from a subclass returns the passed proc created from a symbol" # Expected Proc == ProcSpecs::MyProc to be truthy but was false
  fails "Proc.new with an associated block called on a subclass of Proc returns an instance of the subclass" # Expected Proc == #<Class:0x3fc14> to be truthy but was false
  fails "Proc.new with an associated block called on a subclass of Proc that does not 'super' in 'initialize' still constructs a functional proc" # NoMethodError: undefined method `ok' for #<Proc:0x3fc56>
  fails "Proc.new with an associated block called on a subclass of Proc using a reified block parameter returns an instance of the subclass" # Expected Proc == #<Class:0x3fc3e> to be truthy but was false
  fails "Proc.new with an associated block calls initialize on the Proc object" # ArgumentError: [MyProc2.new] wrong number of arguments (given 2, expected 0)
  fails "Proc.new with an associated block returns a subclass of Proc" # Expected #<Proc:0x3fbfc> (Proc) to be kind of ProcSpecs::MyProc
  fails "Proc.new without a block raises an ArgumentError when passed no block" # Expected ArgumentError (tried to create Proc object without a block) but got: ArgumentError (tried to create a Proc object without a block)
end
