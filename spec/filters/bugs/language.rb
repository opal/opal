opal_filter "language" do
  fails "The alias keyword operates on methods with splat arguments defined in a superclass"
  fails "The alias keyword operates on the object's metaclass when used in instance_eval"
  fails "The alias keyword operates on methods defined via attr, attr_reader, and attr_accessor"
  fails "The alias keyword operates on methods with splat arguments defined in a superclass using text block for class eval"
  fails "The alias keyword is not allowed against Fixnum or String instances"

  fails "The unpacking splat operator (*) when applied to a non-Array value attempts to coerce it to Array if the object respond_to?(:to_a)"
  fails "The unpacking splat operator (*) returns a new array containing the same values when applied to an array inside an empty array"
  fails "The unpacking splat operator (*) unpacks the start and count arguments in an array slice assignment"
  fails "The unpacking splat operator (*) unpacks arguments as if they were listed statically"

  fails "A block arguments with _ assigns the first variable named"
  fails "A block arguments with _ extracts arguments with _"
  fails "A block taking |*a| arguments does not call #to_ary to convert a single yielded object to an Array"
  fails "A block taking |*| arguments does not call #to_ary to convert a single yielded object to an Array"
  fails "A block allows for a leading space before the arguments"
  fails "A block taking |a, b| arguments assigns 'nil' and 'nil' to the arguments when a single, empty Array is yielded"
  fails "A block taking |a, b| arguments assigns the element of a single element Array to the first argument"
  fails "A block taking |a, b| arguments destructures a single Array value yielded"
  fails "A block taking |a, b| arguments calls #to_ary to convert a single yielded object to an Array"
  fails "A block taking |a, b| arguments does not call #to_ary if the single yielded object is an Array"
  fails "A block taking |a, b| arguments raises an TypeError if #to_ary does not return an Array"
  fails "A block taking |a, *b| arguments assigns 'nil' and '[]' to the arguments when a single, empty Array is yielded"
  fails "A block taking |a, *b| arguments assigns the element of a single element Array to the first argument"
  fails "A block taking |a, *b| arguments destructures a single Array value assigning the remaining values to the rest argument"
  fails "A block taking |a, *b| arguments calls #to_ary to convert a single yielded object to an Array"
  fails "A block taking |a, *b| arguments does not call #to_ary if the single yielded object is an Array"
  fails "A block taking |a, *b| arguments raises an TypeError if #to_ary does not return an Array"
  fails "A block taking |*| arguments does not raise an exception when no values are yielded"
  fails "A block taking |*| arguments does not raise an exception when values are yielded"
  fails "A block taking |*| arguments does not call #to_ary if the single yielded object is an Array"
  fails "A block taking |*| arguments does not call #to_ary if the object does not respond to #to_ary"
  fails "A block taking |*a| arguments does not call #to_ary if the single yielded object is an Array"
  fails "A block taking |a, | arguments assigns nil to the argument when no values are yielded"
  fails "A block taking |a, | arguments assgins the argument a single value yielded"
  fails "A block taking |a, | arguments assigns the argument the first value yielded"
  fails "A block taking |a, | arguments assigns the argument the first of several values yielded when it is an Array"
  fails "A block taking |a, | arguments assigns nil to the argument when passed an empty Array"
  fails "A block taking |a, | arguments assigns the argument the first element of the Array when passed a single Array"
  fails "A block taking |a, | arguments calls #to_ary to convert a single yielded object to an Array"
  fails "A block taking |a, | arguments does not call #to_ary if the single yielded object is an Array"
  fails "A block taking |a, | arguments does not call #to_ary if the object does not respond to #to_ary"
  fails "A block taking |a, | arguments raises an TypeError if #to_ary does not return an Array"
  fails "A block taking |(a, b)| arguments calls #to_ary to convert a single yielded object to an Array"
  fails "A block taking |(a, b)| arguments does not call #to_ary if the single yielded object is an Array"
  fails "A block taking |(a, b)| arguments raises an TypeError if #to_ary does not return an Array"
  fails "A block taking |(a, b), c| arguments assigns nil to the arguments when yielded no values"
  fails "A block taking |(a, b), c| arguments destructures a single one-level Array value yielded"
  fails "A block taking |(a, b), c| arguments destructures a single multi-level Array value yielded"
  fails "A block taking |(a, b), c| arguments calls #to_ary to convert a single yielded object to an Array"
  fails "A block taking |(a, b), c| arguments does not call #to_ary if the single yielded object is an Array"
  fails "A block taking |(a, b), c| arguments does not call #to_ary if the object does not respond to #to_ary"
  fails "A block taking |(a, b), c| arguments raises an TypeError if #to_ary does not return an Array"
  fails "A block taking nested |a, (b, (c, d))| assigns nil to the arguments when yielded no values"
  fails "A block taking nested |a, (b, (c, d))| destructures separate yielded values"
  fails "A block taking nested |a, (b, (c, d))| destructures a single multi-level Array value yielded"
  fails "A block taking nested |a, (b, (c, d))| destructures a single multi-level Array value yielded"
  fails "A block taking nested |a, ((b, c), d)| assigns nil to the arguments when yielded no values"
  fails "A block taking nested |a, ((b, c), d)| destructures separate yielded values"
  fails "A block taking nested |a, ((b, c), d)| destructures a single multi-level Array value yielded"
  fails "A block taking nested |a, ((b, c), d)| destructures a single multi-level Array value yielded"

  fails "Break inside a while loop with a splat wraps a non-Array in an Array"
  fails "The break statement in a captured block when the invocation of the scope creating the block is still active raises a LocalJumpError when invoking the block from the scope creating the block"
  fails "The break statement in a captured block when the invocation of the scope creating the block is still active raises a LocalJumpError when invoking the block from a method"
  fails "The break statement in a captured block when the invocation of the scope creating the block is still active raises a LocalJumpError when yielding to the block"
  fails "The break statement in a captured block from a scope that has returned raises a LocalJumpError when calling the block from a method"
  fails "The break statement in a captured block from a scope that has returned raises a LocalJumpError when yielding to the block"
  fails "The break statement in a lambda when the invocation of the scope creating the lambda is still active raises a LocalJumpError when yielding to a lambda passed as a block argument"
  fails "The break statement in a lambda from a scope that has returned raises a LocalJumpError when yielding to a lambda passed as a block argument"
  fails "Executing break from within a block returns from the original invoking method even in case of chained calls"

  fails "The 'case'-construct lets you define a method after the case statement"
  fails "The 'case'-construct with no target expression evaluates true as only 'true' when true is the first clause"

  fails "A class variable can be accessed from a subclass"
  fails "A class variable is set in the superclass"
  fails "A class variable defined in a module can be accessed from classes that extend the module"
  fails "A class variable defined in a module is not defined in these classes"
  fails "A class variable defined in a module is only updated in the module a method defined in the module is used"
  fails "A class variable defined in a module is updated in the class when a Method defined in the class is used"
  fails "A class variable defined in a module can be accessed inside the class using the module methods"
  fails "A class variable defined in a module can be accessed from modules that extend the module"
  fails "A class variable defined in a module is defined in the extended module"
  fails "A class variable defined in a module is not defined in the extending module"

  fails "A class definition raises TypeError if the constant qualifying the class is nil"
  fails "A class definition raises TypeError if any constant qualifying the class is not a Module"
  fails "A class definition allows using self as the superclass if self is a class"
  fails "A class definition raises a TypeError if inheriting from a metaclass"
  fails "A class definition extending an object (sclass) raises a TypeError when trying to extend numbers"
  fails "A class definition extending an object (sclass) allows accessing the block of the original scope"
  fails "A class definition extending an object (sclass) can use return to cause the enclosing method to return"
  fails "An outer class definition contains the inner classes"
  fails "An outer class definition contains the inner classes"
  fails "A class definition stores instance variables defined in the class body in the class object"
  fails "Reopening a class adds new methods to subclasses"

  fails "The def keyword within a closure looks outside the closure for the visibility"
  fails "a method definition that sets more than one default parameter all to the same value treats the argument after the multi-parameter normally"
  fails "a method definition that sets more than one default parameter all to the same value only allows overriding the default value of the first such parameter in each set"
  fails "A method definition in an eval creates a singleton method"
  fails "A method definition in an eval creates a class method"
  fails "A method definition in an eval creates an instance method"
  fails "A method definition inside an instance_eval creates a class method when the receiver is a class"
  fails "A method definition inside a metaclass scope raises RuntimeError if frozen"
  fails "A singleton method defined with extreme default arguments may use a lambda as a default"
  fails "A singleton method defined with extreme default arguments may use preceding arguments as defaults"
  fails "A singleton method defined with extreme default arguments evaluates the defaults in the singleton scope"
  fails "A singleton method defined with extreme default arguments may use an fcall as a default"
  fails "A singleton method defined with extreme default arguments may use a method definition as a default"
  fails "A method defined with extreme default arguments may use an fcall as a default"
  fails "A method defined with extreme default arguments can redefine itself when the default is evaluated"
  fails "Redefining a singleton method does not inherit a previously set visibility "
  fails "Redefining a singleton method does not inherit a previously set visibility "
  fails "A singleton method definition raises RuntimeError if frozen"
  fails "A singleton method definition can be declared for a class variable"
  fails "A singleton method definition can be declared for a global variable"
  fails "A singleton method definition can be declared for an instance variable"
  fails "A singleton method definition can be declared for a local variable"
  fails "Defining an 'initialize' method sets the method's visibility to private"
  fails "Defining an 'initialize_copy' method sets the method's visibility to private"

  fails "The defined? keyword when called with a method name having a module as a receiver returns nil if the method is private"

  fails "An ensure block inside a begin block is executed even when a symbol is thrown in it's corresponding begin block"
  fails "An ensure block inside a method is executed even when a symbol is thrown in the method"

  fails "`` returns the output of the executed sub-process"
  fails "%x is the same as ``"

  fails "The for expression repeats current iteration with 'redo'"
  fails "The for expression starts the next iteration with 'next'"
  fails "The for expression allows 'break' to have an argument which becomes the value of the for expression"
  fails "The for expression breaks out of a loop upon 'break', returning nil"
  fails "The for expression returns expr"
  fails "The for expression executes code in containing variable scope with 'do'"
  fails "The for expression executes code in containing variable scope"
  fails "The for expression allows body begin on the same line if do is used"
  fails "The for expression optionally takes a 'do' after the expression"
  fails "The for expression yields only as many values as there are arguments"
  fails "The for expression allows a constant as an iterator name"
  fails "The for expression allows a class variable as an iterator name"
  fails "The for expression allows an instance variable as an iterator name"
  fails "The for expression iterates over any object responding to 'each'"
  fails "The for expression iterates over an Hash passing each key-value pair to the block"
  fails "The for expression iterates over an Enumerable passing each element to the block"

  fails "The if expression with a boolean range ('flip-flop' operator) keeps flip-flops from interfering"
  fails "The if expression with a boolean range ('flip-flop' operator) scopes state by flip-flop"
  fails "The if expression with a boolean range ('flip-flop' operator) evaluates the second conditions lazily with exclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) evaluates the second conditions lazily with inclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) evaluates the first conditions lazily with exclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) evaluates the first conditions lazily with inclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) allows combining two flip-flops"
  fails "The if expression with a boolean range ('flip-flop' operator) mimics a sed conditional with a many-element exclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) mimics a sed conditional with a zero-element exclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) mimics an awk conditional with a many-element inclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) mimics an awk conditional with a single-element inclusive-end range"

  fails "calling methods on the metaclass calls a method defined on the metaclass of the metaclass"
  fails "calling methods on the metaclass calls a method in deeper chains of metaclasses"
  fails "A constant on a metaclass is preserved when the object is cloned"
  fails "A constant on a metaclass is not preserved when the object is duped"
  fails "A constant on a metaclass does not appear in the object's class constant list"
  fails "A constant on a metaclass appears in the metaclass constant list"
  fails "A constant on a metaclass raises a NameError for anonymous_module::CONST"
  fails "A constant on a metaclass cannot be accessed via object::CONST"
  fails "A constant on a metaclass is not defined in the metaclass opener's scope"
  fails "A constant on a metaclass is not defined on the object's class"
  fails "self in a metaclass body (class << obj) raises a TypeError for symbols"
  fails "self in a metaclass body (class << obj) raises a TypeError for numbers"

  fails "The module keyword raises a TypeError if the constant in nil"
  fails "The module keyword creates a new module with a variable qualified constant name"
  fails "The module keyword creates a new module with a qualified constant name"
  fails "The module keyword creates a new module with a non-qualified constant name"

  fails "Assignment via next assigns splatted objects"

  fails "The or operator has a lower precedence than 'next' in 'next true or false'"

  fails "A method call evaluates block pass after arguments"
  fails "A method call evaluates arguments after receiver"

  fails "Operators or/and have higher precedence than if unless while until modifiers"
  fails "Operators = %= /= -= += |= &= >>= <<= *= &&= ||= **= have higher precedence than defined? operator"
  fails "Operators = %= /= -= += |= &= >>= <<= *= &&= ||= **= are right-associative"
  fails "Operators rescue has higher precedence than ="
  fails "Operators + - have higher precedence than >> <<"
  fails "Operators + - are left-associative"
  fails "Operators * / % are left-associative"

  fails "A Proc taking |(a, b)| arguments raises an TypeError if #to_ary does not return an Array"
  fails "A Proc taking |(a, b)| arguments calls #to_ary to convert a single passed object to an Array"
  fails "A Proc taking |(a, b)| arguments destructures a single Array value yielded"
  fails "A Proc taking |(a, b)| arguments raises an ArgumentError when passed no values"
  fails "A Proc taking |a, | arguments does not call #to_ary to convert a single passed object to an Array"
  fails "A Proc taking |a, | arguments does not destructure when passed a single Array"
  fails "A Proc taking |a, | arguments assigns the argument the value passed"
  fails "A Proc taking |a, | arguments raises an ArgumentError when passed more than one value"
  fails "A Proc taking |a, | arguments raises an ArgumentError when passed no values"
  fails "A Proc taking |*a| arguments does not call #to_ary to convert a single passed object to an Array"
  fails "A Proc taking |*| arguments does not call #to_ary to convert a single passed object to an Array"
  fails "A Proc taking |*| arguments does not raise an exception when passed multiple values"
  fails "A Proc taking |*| arguments does not raise an exception when passed no values"
  fails "A Proc taking |a, *b| arguments does not call #to_ary to convert a single passed object to an Array"
  fails "A Proc taking |a, *b| arguments raises an ArgumentError if passed no values"
  fails "A Proc taking |a, b| arguments does not call #to_ary to convert a single passed object to an Array"
  fails "A Proc taking |a, b| arguments raises an ArgumentError if passed one value"
  fails "A Proc taking |a, b| arguments raises an ArgumentError if passed no values"
  fails "A Proc taking |a| arguments raises an ArgumentError if no value is passed"
  fails "A Proc taking |a| arguments does not call #to_ary to convert a single passed object to an Array"
  fails "A Proc taking || arguments raises an ArgumentError if a value is passed"
  fails "A Proc taking zero arguments raises an ArgumentErro if a value is passed"

  fails "The redo statement re-executes the closest loop"

  fails "The rescue keyword parses  'a += b rescue c' as 'a += (b rescue c)'"
  fails "The rescue keyword will not rescue errors raised in an else block in the rescue block above it"
  fails "The rescue keyword will not execute an else block if an exception was raised"
  fails "The rescue keyword will execute an else block only if no exceptions were raised"
  fails "The rescue keyword will only rescue the specified exceptions when doing a splat rescue"
  fails "The rescue keyword can rescue a splatted list of exceptions"
  fails "The rescue keyword can rescue multiple raised exceptions with a single rescue block"

  fails "The retry statement re-executes the closest block"
  fails "The retry statement raises a SyntaxError when used outside of a begin statement"
  fails "The retry keyword inside a begin block's rescue block causes the begin block to be executed again"

  fails "The return keyword within a begin returns last value returned in nested ensures"
  fails "The return keyword within a begin executes nested ensures before returning"
  fails "The return keyword when passed a splat calls 'to_a' on the splatted value first"
  fails "The return keyword when passed a splat returns an array when used as a splat"
  fails "The return keyword in a Thread raises a LocalJumpError if used to exit a thread"

  fails "Invoking a private getter method does not permit self as a receiver"
  fails "Invoking a method with manditory and optional arguments raises an ArgumentError if too many values are passed"
  fails "Invoking a method with optional arguments raises ArgumentError if extra arguments are passed"
  # fails "Invoking a method passes a literal hash without curly braces or parens"
  # fails "Invoking a method passes literal hashes without curly braces as the last parameter"
  fails "Invoking a method raises a SyntaxError with both a literal block and an object as block"
  fails "Invoking a method with an object as a block uses 'to_proc' for coercion"

  fails "Instantiating a singleton class raises a TypeError when allocate is called"
  fails "Instantiating a singleton class raises a TypeError when new is called"
  fails "Class methods of a singleton class for a singleton class include class methods of the singleton class of Class"
  fails "Class methods of a singleton class for a class include instance methods of the singleton class of Class"
  fails "Class methods of a singleton class for a class include class methods of Class"
  fails "Instance methods of a singleton class for a singleton class includes instance methods of the singleton class of Class"
  fails "Defining instance methods on a singleton class define public methods"
  fails "A constant on a singleton class is preserved when the object is cloned"
  fails "A constant on a singleton class is not preserved when the object is duped"
  fails "A constant on a singleton class does not appear in the object's class constant list"
  fails "A constant on a singleton class raises a NameError for anonymous_module::CONST"
  fails "A constant on a singleton class cannot be accessed via object::CONST"
  fails "A constant on a singleton class is not defined in the singleton class opener's scope"
  fails "A constant on a singleton class is not defined on the object's class"
  fails "A singleton class doesn't have singleton class"
  fails "A singleton class for BasicObject has the proper level of superclass for Class"
  fails "A singleton class for BasicObject has Class as it's superclass"
  fails "A singleton class is a subclass of the same level of superclass's singleton class"
  fails "A singleton class is a subclass of a superclass's singleton class"
  fails "A singleton class is a subclass of the same level of Class's singleton class"
  fails "A singleton class is a subclass of Class's singleton class"
  fails "A singleton class inherits from Class for classes"
  fails "A singleton class is a singleton Class instance"
  fails "A singleton class raises a TypeError for symbols"
  fails "A singleton class raises a TypeError for Fixnum's"

  fails "The super keyword searches class methods including modules"
  fails "The super keyword calls the correct method when the method visibility is modified"
  fails "The super keyword passes along modified rest args when they were originally empty"
  fails "The super keyword passes along modified rest args when they weren't originally empty"
  fails "The super keyword sees the included version of a module a method is alias from"
  fails "The super keyword can't be used with implicit arguments from a method defined with define_method"
  fails "The super keyword raises an error error when super method does not exist"
  fails "The super keyword calls the correct method when the superclass argument list is different from the subclass"
  fails "The super keyword respects the original module a method is aliased from"

  fails "The until modifier with begin .. end block restart the current iteration without reevaluting condition with redo"
  fails "The until modifier with begin .. end block skips to end of body with next"
  fails "The until modifier with begin .. end block evaluates condition after block execution"
  fails "The until modifier with begin .. end block runs block at least once (even if the expression is true)"
  fails "The until modifier restarts the current iteration without reevaluating condition with redo"
  fails "The until expression restarts the current iteration without reevaluating condition with redo"

  fails "Multiple assignment, array-style returns an array of all rhs values"
  fails "Multiple assignment has the proper return value"
  fails "Multiple assignments with grouping supports multiple levels of nested groupings"
  fails "Multiple assignments with grouping A group on the lhs is considered one position and treats its corresponding rhs position like an Array"
  fails "Operator assignment 'obj[idx] op= expr' returns result of rhs not result of []="
  fails "Operator assignment 'obj[idx] op= expr' handles splat index (idx) arguments with normal arguments"
  fails "Operator assignment 'obj[idx] op= expr' handles multiple splat index (idx) arguments"
  fails "Operator assignment 'obj[idx] op= expr' handles single splat index (idx) arguments"
  fails "Operator assignment 'obj[idx] op= expr' handles empty splat index (idx) arguments"
  fails "Operator assignment 'obj[idx] op= expr' handles complex index (idx) arguments"
  fails "Operator assignment 'obj[idx] op= expr' handles empty index (idx) arguments"
  fails "Conditional operator assignment 'obj[idx] op= expr' uses short-circuit arg evaluation"
  fails "Conditional operator assignment 'obj[idx] op= expr' may not assign at all, depending on the truthiness of lhs"
  fails "Conditional operator assignment 'obj[idx] op= expr' is equivalent to 'obj[idx] op obj[idx] = expr'"
  fails "Unconditional operator assignment 'obj[idx] op= expr' is equivalent to 'obj[idx] = obj[idx] op expr'"
  fails "Conditional operator assignment 'obj.meth op= expr' uses short-circuit arg evaluation"
  fails "Conditional operator assignment 'obj.meth op= expr' may not assign at all, depending on the truthiness of lhs"
  fails "Conditional operator assignment 'var op= expr' uses short-circuit arg evaluation"
  fails "Conditional operator assignment 'var op= expr' may not assign at all, depending on the truthiness of lhs"
  fails "Assigning multiple values allows complex parallel assignment"
  fails "Assigning multiple values calls #to_ary on RHS arg if the corresponding LHS var is a splat"
  fails "Assigning multiple values returns the rhs values used for assignment as an array"
  fails "Basic multiple assignment with a splatted single RHS value does not call #to_ary on an object"
  fails "Basic multiple assignment with a splatted single RHS value calls #to_a on an object if #to_ary is not defined"
  fails "Basic multiple assignment with a splatted single RHS value does not call #to_a on an Array subclass instance"
  fails "Basic multiple assignment with a splatted single RHS value does not call #to_ary on an Array subclass instance"
  fails "Basic multiple assignment with a splatted single RHS value does not call #to_a on an Array instance"
  fails "Basic multiple assignment with a splatted single RHS value does not call #to_ary on an Array instance"
  fails "Basic multiple assignment with a single RHS value does not call #to_a on an object if #to_ary is not defined"
  fails "Basic multiple assignment with a single RHS value calls #to_ary on an object"
  fails "Basic multiple assignment with a single RHS value does not call #to_a on an Array subclass instance"
  fails "Basic multiple assignment with a single RHS value does not call #to_ary on an Array subclass instance"
  fails "Basic multiple assignment with a single RHS value does not call #to_a on an Array instance"
  fails "Basic multiple assignment with a single RHS value does not call #to_ary on an Array instance"
  fails "Basic assignment allows the assignment of the rhs to the lhs using the rhs splat operator"
  fails "Multiple assignments with splats * on the LHS has to be applied to any parameter"

  fails "The while modifier with begin .. end block runs block at least once (even if the expression is false)"
  fails "The while modifier with begin .. end block evaluates condition after block execution"
  fails "The while modifier with begin .. end block skips to end of body with next"
  fails "The while modifier with begin .. end block restarts the current iteration without reevaluting condition with redo"

  fails "The yield call taking no arguments ignores assignment to the explicit block argument and calls the passed block"
  fails "The yield call taking a single splatted argument passes no values when give nil as an argument"
  fails "The yield call taking multiple arguments with a splat does not pass an argument value if the splatted argument is nil"

  fails "The defined? keyword when called with a method name without a receiver returns nil if the method is not defined"
  fails "The defined? keyword when called with a method name having a module as receiver returns nil if the method is private"
  fails "The defined? keyword when called with a method name having a module as receiver returns nil if the method is protected"
  fails "The defined? keyword when called with a method name having a module as receiver returns nil if the method is not defined"
  fails "The defined? keyword when called with a method name having a module as receiver returns nil if the class is not defined"
  fails "The defined? keyword when called with a method name having a module as receiver returns nil if the subclass is not defined"
  fails "The defined? keyword when called with a method name having a local variable as receiver returns nil if the variable does not exist"
  fails "The defined? keyword when called with a method name having a global variable as receiver returns nil if the variable does not exist"
  fails "The defined? keyword when called with a method name having a method call as a receiver returns nil if evaluating the receiver raises an exception"
  fails "The defined? keyword for an expression returns nil for an expression with == and an undefined method"
  fails "The defined? keyword for an expression returns nil for an expression with != and an undefined method"
  fails "The defined? keyword for an expression returns nil for an expression with !~ and an undefined method"
  fails "The defined? keyword for an expression with logical connectives returns nil for an expression with '!' and an undefined method"
  fails "The defined? keyword for an expression with logical connectives returns nil for an expression with 'not' and an undefined method"
  fails "The defined? keyword for an expression with logical connectives does not propagate an exception raised by a method in a 'not' expression"
  fails "The defined? keyword for an expression with logical connectives calls a method in a 'not' expression and returns 'method'"
  fails "The defined? keyword for variables when a String matches a Regexp returns nil for non-captures"
  fails "The defined? keyword for variables when a Regexp matches a String returns nil for non-captures"
  fails "The defined? keyword for a simple constant returns 'constant' when the constant is defined"
  fails "The defined? keyword for a simple constant returns nil when the constant is not defined"
  fails "The defined? keyword for a simple constant does not call Object.const_missing if the constant is not defined"
  fails "The defined? keyword for a simple constant returns 'constant' for an included module"
  fails "The defined? keyword for a simple constant returns 'constant' for a constant defined in an included module"
  fails "The defined? keyword for a scoped constant does not call .const_missing if the constant is not defined"
  fails "The defined? keyword for yield returns nil if no block is passed to a method not taking a block parameter"
  fails "The defined? keyword for yield returns nil if no block is passed to a method taking a block parameter"
  fails "The defined? keyword for super returns nil when a superclass undef's the method"
  fails "The defined? keyword for super for a method taking no arguments returns nil when no superclass method exists"
  fails "The defined? keyword for super for a method taking no arguments returns nil from a block when no superclass method exists"
  fails "The defined? keyword for super for a method taking arguments returns nil when no superclass method exists"
  fails "The defined? keyword for super for a method taking arguments returns nil from a block when no superclass method exists"

end
