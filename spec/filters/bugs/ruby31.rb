opal_filter "Ruby 3.1" do
  fails "$LOAD_PATH.resolve_feature_path return nil if feature cannot be found" # NoMethodError: undefined method `resolve_feature_path' for ["foo"]
  fails "Array#intersect? when at least one element in two Arrays is the same returns true" # NoMethodError: undefined method `intersect?' for [1, 2]
  fails "Array#intersect? when there are no elements in common between two Arrays returns false" # NoMethodError: undefined method `intersect?' for [1, 2]
  fails "Class#descendants does not return included modules" # NoMethodError: undefined method `descendants' for #<Class:0x4102c>
  fails "Class#descendants does not return singleton classes" # NoMethodError: undefined method `descendants' for #<Class:0x41032>
  fails "Class#descendants has 1 entry per module or class" # NoMethodError: undefined method `descendants' for ModuleSpecs::Parent
  fails "Class#descendants returns a list of classes descended from self (excluding self)" # NoMethodError: undefined method `descendants' for ModuleSpecs::Parent
  fails "Class#subclasses does not return included modules" # NoMethodError: undefined method `subclasses' for #<Class:0x25eae>
  fails "Class#subclasses does not return singleton classes" # NoMethodError: undefined method `subclasses' for #<Class:0x25eb4>
  fails "Class#subclasses has 1 entry per module or class" # NoMethodError: undefined method `subclasses' for ModuleSpecs::Parent
  fails "Class#subclasses returns a list of classes directly inheriting from self" # NoMethodError: undefined method `subclasses' for ModuleSpecs::Parent
  fails "Enumerable#tally with a hash does not call given block" # ArgumentError: [Numerous#tally] wrong number of arguments(1 for 0)
  fails "Enumerable#tally with a hash ignores the default proc" # ArgumentError: [Numerous#tally] wrong number of arguments(1 for 0)
  fails "Enumerable#tally with a hash ignores the default value" # ArgumentError: [Numerous#tally] wrong number of arguments(1 for 0)
  fails "Enumerable#tally with a hash needs the values counting each elements to be an integer" # Expected TypeError but got: ArgumentError ([Numerous#tally] wrong number of arguments(1 for 0))
  fails "Enumerable#tally with a hash raises a FrozenError and does not update the given hash when the hash is frozen" # Expected FrozenError but got: ArgumentError ([Numerous#tally] wrong number of arguments(1 for 0))
  fails "Enumerable#tally with a hash returns a hash with counts according to the value" # ArgumentError: [Numerous#tally] wrong number of arguments(1 for 0)
  fails "Enumerable#tally with a hash returns the given hash" # ArgumentError: [Numerous#tally] wrong number of arguments(1 for 0)
  fails "File.dirname returns all the components of filename except the last parts by the level" # ArgumentError: [File.dirname] wrong number of arguments(2 for 1)
  fails "File.dirname returns the same string if the level is 0" # ArgumentError: [File.dirname] wrong number of arguments(2 for 1)
  fails "Hash literal checks duplicated float keys on initialization" # Expected warning to match: /key 1.0 is duplicated|duplicated key/ but got: ""
  fails "Integer.try_convert does not rescue exceptions raised by #to_int" # Expected RuntimeError but got: NoMethodError (undefined method `try_convert' for Integer)
  fails "Integer.try_convert does not rescue exceptions raised by #to_int" # Expected RuntimeError but got: NoMethodError (undefined method `try_convert' for Integer)
  fails "Integer.try_convert does not rescue exceptions raised by #to_int" # Mock 'to_int' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "Integer.try_convert does not rescue exceptions raised by #to_int" # Mock 'to_int' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "Integer.try_convert returns nil when the argument does not respond to #to_int" # NoMethodError: undefined method `try_convert' for Integer
  fails "Integer.try_convert returns nil when the argument does not respond to #to_int" # NoMethodError: undefined method `try_convert' for Integer
  fails "Integer.try_convert returns the argument if it's an Integer" # NoMethodError: undefined method `try_convert' for Integer
  fails "Integer.try_convert returns the argument if it's an Integer" # NoMethodError: undefined method `try_convert' for Integer
  fails "Integer.try_convert sends #to_int to the argument and raises TypeError if it's not a kind of Integer" # Expected TypeError but got: NoMethodError (undefined method `try_convert' for Integer)
  fails "Integer.try_convert sends #to_int to the argument and raises TypeError if it's not a kind of Integer" # Expected TypeError but got: NoMethodError (undefined method `try_convert' for Integer)
  fails "Integer.try_convert sends #to_int to the argument and raises TypeError if it's not a kind of Integer" # Mock 'to_int' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "Integer.try_convert sends #to_int to the argument and raises TypeError if it's not a kind of Integer" # Mock 'to_int' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "Integer.try_convert sends #to_int to the argument and returns the result if it's an Integer" # Mock 'to_int' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "Integer.try_convert sends #to_int to the argument and returns the result if it's an Integer" # Mock 'to_int' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "Integer.try_convert sends #to_int to the argument and returns the result if it's an Integer" # NoMethodError: undefined method `try_convert' for Integer
  fails "Integer.try_convert sends #to_int to the argument and returns the result if it's an Integer" # NoMethodError: undefined method `try_convert' for Integer
  fails "Integer.try_convert sends #to_int to the argument and returns the result if it's nil" # Mock 'to_int' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "Integer.try_convert sends #to_int to the argument and returns the result if it's nil" # Mock 'to_int' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "Integer.try_convert sends #to_int to the argument and returns the result if it's nil" # NoMethodError: undefined method `try_convert' for Integer
  fails "Integer.try_convert sends #to_int to the argument and returns the result if it's nil" # NoMethodError: undefined method `try_convert' for Integer
  fails "Marshal.load when called with freeze: true does not freeze classes" # ArgumentError: [Marshal.load] wrong number of arguments(2 for 1)
  fails "Marshal.load when called with freeze: true does not freeze modules" # ArgumentError: [Marshal.load] wrong number of arguments(2 for 1)
  fails "Marshal.load when called with freeze: true returns frozen arrays" # ArgumentError: [Marshal.load] wrong number of arguments(2 for 1)
  fails "Marshal.load when called with freeze: true returns frozen hashes" # ArgumentError: [Marshal.load] wrong number of arguments(2 for 1)
  fails "Marshal.load when called with freeze: true returns frozen objects" # ArgumentError: [Marshal.load] wrong number of arguments(2 for 1)
  fails "Marshal.load when called with freeze: true returns frozen regexps" # ArgumentError: [Marshal.load] wrong number of arguments(2 for 1)
  fails "Marshal.load when called with freeze: true returns frozen strings" # ArgumentError: [Marshal.load] wrong number of arguments(2 for 1)
  fails "Marshal.load when called with freeze: true when called with a proc call the proc with frozen objects" # ArgumentError: [Marshal.load] wrong number of arguments(3 for 1)
  fails "Marshal.load when called with freeze: true when called with a proc does not freeze the object returned by the proc" # ArgumentError: [Marshal.load] wrong number of arguments(3 for 1)
  fails "MatchData#match returns nil on non-matching index matches" # NoMethodError: undefined method `match' for #<MatchData "1138" 1:nil>
  fails "MatchData#match returns nil on non-matching index matches" # NoMethodError: undefined method `match' for #<MatchData "t" t:"t" a:nil>
  fails "MatchData#match returns the corresponding match when given an Integer" # NoMethodError: undefined method `match' for #<MatchData "HX1138" 1:"H" 2:"X" 3:"113" 4:"8">
  fails "MatchData#match returns the corresponding named match when given a Symbol" # NoMethodError: undefined method `match' for #<MatchData "tack" t:"tack" a:"ack">
  fails "MatchData#match_length returns nil on non-matching index matches" # NoMethodError: undefined method `match_length' for #<MatchData "1138" 1:nil>
  fails "MatchData#match_length returns nil on non-matching index matches" # NoMethodError: undefined method `match_length' for #<MatchData "t" t:"t" a:nil>
  fails "MatchData#match_length returns the length of the corresponding match when given an Integer" # NoMethodError: undefined method `match_length' for #<MatchData "HX1138" 1:"H" 2:"X" 3:"113" 4:"8">
  fails "MatchData#match_length returns the length of the corresponding named match when given a Symbol" # NoMethodError: undefined method `match_length' for #<MatchData "tack" t:"tack" a:"ack">
  fails "Module#module_function as a toggle (no arguments) in a Module body returns nil" # Expected #<Module:0xb5a4> to be identical to nil
  fails "Module#module_function with specific method names returns argument or arguments if given" # Expected #<Module:0xb352> to be identical to "foo"
  fails "Module#private returns argument or arguments if given" # Expected nil to be identical to "foo"
  fails "Module#protected returns argument or arguments if given" # Expected nil to be identical to "foo"
  fails "Module#public returns argument or arguments if given" # Expected nil to be identical to "foo"
  fails "Pattern matching warning when one-line form does not warn about pattern matching is experimental feature" # NameError: uninitialized constant Warning
  fails "Pattern matching warning when one-line form does not warn about pattern matching is experimental feature" # NameError: uninitialized constant Warning
  fails "Range#step with exclusive end and Float values correctly handles values near the upper limit" # Expected 3 == 4 to be truthy but was false
  fails "String#lstrip strips leading \\0" # Expected "\u0000hello" == "hello" to be truthy but was false
  fails "String#lstrip! strips leading \\0" # NotImplementedError: String#lstrip! not supported. Mutable String methods are not supported in Opal.
  fails "String#split with String when $; is not nil warns" # Expected warning to match: /warning: \$; is set to non-nil value/ but got: ""
  fails "String#strip returns a copy of self without leading and trailing NULL bytes and whitespace" # Expected "\u0000 goodbye" == "goodbye" to be truthy but was false
  fails "String#strip! removes leading and trailing NULL bytes and whitespace" # NotImplementedError: String#strip! not supported. Mutable String methods are not supported in Opal.
  fails "String#unpack with directive 'w' returns nil if the offset is at the end of the string" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with directive 'w' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'A' returns nil if the offset is at the end of the string" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'A' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'B' returns nil if the offset is at the end of the string" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'B' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'C' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'H' returns nil if the offset is at the end of the string" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'H' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'L' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'M' returns nil if the offset is at the end of the string" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'M' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'N' returns nil if the offset is at the end of the string" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'N' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'Q' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'S' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'U' returns nil if the offset is at the end of the string" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'U' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'V' returns nil if the offset is at the end of the string" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'V' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'Z' returns nil if the offset is at the end of the string" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'Z' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'a' returns nil if the offset is at the end of the string" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'a' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'b' returns nil if the offset is at the end of the string" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'b' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'c' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'h' returns nil if the offset is at the end of the string" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'h' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'l' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'm' returns nil if the offset is at the end of the string" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'm' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'n' returns nil if the offset is at the end of the string" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'n' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'q' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 's' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'u' returns nil if the offset is at the end of the string" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'u' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'v' returns nil if the offset is at the end of the string" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack with format 'v' starts unpacking from the given offset" # ArgumentError: [String#unpack] wrong number of arguments(2 for 1)
  fails "String#unpack1 returns nil if the offset is at the end of the string" # ArgumentError: [String#unpack1] wrong number of arguments(2 for 1)
  fails "String#unpack1 starts unpacking from the given offset" # ArgumentError: [String#unpack1] wrong number of arguments(2 for 1)
  fails "The ** operator hash with omitted value accepts mixed syntax" # NameError: uninitialized constant MSpecEnv::a
  fails "The ** operator hash with omitted value accepts short notation 'key' for 'key: value' syntax" # NameError: uninitialized constant MSpecEnv::a
  fails "The ** operator hash with omitted value ignores hanging comma on short notation" # NameError: uninitialized constant MSpecEnv::a
  fails "The ** operator hash with omitted value works with methods and local vars" # NameError: uninitialized constant #<Class:0x874c0>::bar
  fails "kwarg with omitted value in a method call accepts short notation 'kwarg' in method call for definition 'def call(*args, **kwargs) = [args, kwargs]'" # NameError: uninitialized constant SpecEvaluate::a
  fails "kwarg with omitted value in a method call with methods and local variables for definition \n    def call(*args, **kwargs) = [args, kwargs]\n    def bar\n      \"baz\"\n    end\n    def foo(val)\n      call bar:, val:\n    end" # NameError: uninitialized constant SpecEvaluate::bar
  fails "main#private returns argument" # Expected nil to be identical to "main_public_method"
  fails "main#public returns argument" # Expected nil to be identical to "main_private_method"
end
