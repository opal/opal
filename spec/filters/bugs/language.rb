opal_filter "language" do
  fails "A block yielded a single Array assigns elements to required arguments when a keyword rest argument is present"
  fails "A block yielded a single Array assigns non-symbol keys to non-keyword arguments"
  fails "A block yielded a single Array assigns symbol keys from a Hash returned by #to_hash to keyword arguments"
  fails "A block yielded a single Array assigns symbol keys from a Hash to keyword arguments"
  fails "A block yielded a single Array assigns the last element to a non-keyword argument if #to_hash returns nil"
  fails "A block yielded a single Array calls #to_hash on the argument but does not use the result when no keywords are present"
  fails "A block yielded a single Array does not treat hashes with string keys as keyword arguments"
  fails "A block yielded a single Array raises a TypeError if #to_hash does not return a Hash"
  fails "A class definition allows using self as the superclass if self is a class"
  fails "A class definition extending an object (sclass) can use return to cause the enclosing method to return"
  fails "A class definition extending an object (sclass) raises a TypeError when trying to extend numbers"
  fails "A class definition raises TypeError if any constant qualifying the class is not a Module"
  fails "A class definition raises TypeError if the constant qualifying the class is nil"
  fails "A class definition raises a TypeError if inheriting from a metaclass"
  fails "A constant on a metaclass cannot be accessed via object::CONST"
  fails "A constant on a singleton class cannot be accessed via object::CONST"
  fails "A lambda expression 'lambda { ... }' assigns variables from parameters for definition \n    def m(a) yield a end\n    def m2() yield end\n    @a = lambda { |a, | a }"
  fails "A lambda expression 'lambda { ... }' requires a block"
  fails "A lambda expression 'lambda { ... }' with an implicit block can be created"
  fails "A lambda literal -> () { } assigns variables from parameters with circular optional argument reference shadows an existing local with the same name as the argument"
  fails "A lambda literal -> () { } assigns variables from parameters with circular optional argument reference shadows an existing method with the same name as the argument"
  fails "A lambda literal -> () { } returns a Proc object when used in a BasicObject method"
  fails "A method definition in an eval creates a class method"
  fails "A method definition in an eval creates a singleton method"
  fails "A method definition in an eval creates an instance method"
  fails "A nested method definition creates a class method when evaluated in a class method"
  fails "A nested method definition creates a method in the surrounding context when evaluated in a def expr.method"
  fails "A nested method definition creates an instance method when evaluated in an instance method"
  fails "A number literal can be a decimal literal with trailing 'r' to represent a Rational" # requires String#to_r
  fails "A singleton class doesn't have singleton class"
  fails "A singleton class raises a TypeError for Fixnum's"
  fails "A singleton class raises a TypeError for symbols"
  fails "A singleton method definition can be declared for a global variable"
  fails "An ensure block inside a begin block is executed even when a symbol is thrown in it's corresponding begin block"
  fails "An instance method with a default argument shadows an existing method with the same name as the local"
  fails "Constant resolution within methods with dynamically assigned constants searches Object as a lexical scope only if Object is explicitly opened"
  fails "Constant resolution within methods with statically assigned constants searches Object as a lexical scope only if Object is explicitly opened"
  fails "Constant resolution within methods with ||= assignes constant if previously undefined"
  fails "Executing break from within a block returns from the original invoking method even in case of chained calls"
  fails "Execution variable $: is initialized to an array of strings"
  fails "Execution variable $: is read-only"
  fails "Execution variable $: is the same object as $LOAD_PATH and $-I"
  fails "Global variable $-a is read-only"
  fails "Global variable $-d is an alias of $DEBUG"
  fails "Global variable $-l is read-only"
  fails "Global variable $-p is read-only"
  fails "Global variable $-v is an alias of $VERBOSE"
  fails "Global variable $-w is an alias of $VERBOSE"
  fails "Global variable $0 is the path given as the main script and the same as __FILE__"
  fails "Global variable $0 raises a TypeError when not given an object that can be coerced to a String"
  fails "Global variable $< is read-only"
  fails "Global variable $? is read-only"
  fails "Global variable $? is thread-local"
  fails "Global variable $FILENAME is read-only"
  fails "Global variable $\" is read-only"
  fails "Hash literal expands a BasicObject using ** into the containing Hash literal initialization" # NoMethodError: undefined method `respond_to?' for BasicObject
  fails "Instantiating a singleton class raises a TypeError when allocate is called"
  fails "Instantiating a singleton class raises a TypeError when new is called"
  fails "Invoking a method does not expand final array arguments after a splat expansion"
  fails "Literal (A::X) constant resolution raises a TypeError if a non-class or non-module qualifier is given"
  fails "Literal (A::X) constant resolution with dynamically assigned constants evaluates the right hand side before evaluating a constant path"
  fails "Literal Regexps caches the Regexp object"
  fails "Literal Regexps supports (?# )"
  fails "Literal Regexps supports (?<! ) (negative lookbehind)"
  fails "Literal Regexps supports (?<= ) (positive lookbehind)"
  fails "Literal Regexps supports (?> ) (embedded subexpression)"
  fails "Literal Regexps supports \\g (named backreference)"
  fails "Literal Regexps supports character class composition"
  fails "Literal Regexps supports conditional regular expressions with named capture groups" # Exception: named captures are not supported in javascript: "^(?<word>foo)?(?(<word>)(T)|(F))$"
  fails "Literal Regexps supports conditional regular expressions with positional capture groups" # Exception: Invalid regular expression: /^(foo)?(?(1)(T)|(F))$/: Invalid group
  fails "Literal Regexps supports conditional regular expressions with positional capture groups" # Exception: named captures are not supported in javascript: "^(?<word>foo)?(?(<word>)(T)|(F))$"
  fails "Literal Regexps supports possessive quantifiers"
  fails "Literal Regexps throws SyntaxError for malformed literals"
  fails "Magic comment is optional"
  fails "Operators * / % are left-associative"
  fails "Optional variable assignments using compunded constants with ||= assignments"
  fails "Post-args with optional args with a circular argument reference shadows an existing local with the same name as the argument"
  fails "Post-args with optional args with a circular argument reference shadows an existing method with the same name as the argument"
  fails "Predefined global $+ captures the last non nil capture"
  fails "Predefined global $+ is equivalent to $~.captures.last"
  fails "Predefined global $, raises TypeError if assigned a non-String"
  fails "Predefined global $-0 changes $/"
  fails "Predefined global $-0 does not call #to_str to convert the object to a String"
  fails "Predefined global $-0 raises a TypeError if assigned a Fixnum"
  fails "Predefined global $-0 raises a TypeError if assigned a boolean"
  fails "Predefined global $/ changes $-0"
  fails "Predefined global $/ does not call #to_str to convert the object to a String"
  fails "Predefined global $/ raises a TypeError if assigned a Fixnum"
  fails "Predefined global $/ raises a TypeError if assigned a boolean"
  fails "Predefined global $_ is Thread-local"
  fails "Predefined global $_ is set at the method-scoped level rather than block-scoped"
  fails "Predefined global $_ is set to the last line read by e.g. StringIO#gets"
  fails "Predefined global $stdout raises TypeError error if assigned to nil"
  fails "Predefined global $stdout raises TypeError error if assigned to object that doesn't respond to #write"
  fails "Predefined global $~ is set at the method-scoped level rather than block-scoped"
  fails "Predefined global $~ raises an error if assigned an object not nil or instanceof MatchData"
  fails "Safe navigator allows assignment methods"
  fails "Safe navigator allows assignment operators"
  fails "Safe navigator does not call the operator method lazily with an assignment operator"
  fails "The =~ operator with named captures on syntax of /regexp/ =~ string_variable sets local variables by the captured pairs"
  fails "The =~ operator with named captures on syntax of regexp_variable =~ string_variable does not set local variables"
  fails "The =~ operator with named captures on syntax of string_variable =~ /regexp/ does not set local variables"
  fails "The =~ operator with named captures on the method calling does not set local variables"
  fails "The BEGIN keyword accesses variables outside the eval scope"
  fails "The BEGIN keyword runs first in a given code unit"
  fails "The BEGIN keyword runs in a shared scope"
  fails "The BEGIN keyword runs multiple begins in FIFO order"
  fails "The __ENCODING__ pseudo-variable is US-ASCII by default"
  fails "The __ENCODING__ pseudo-variable is the encoding specified by a magic comment in the file"
  fails "The __ENCODING__ pseudo-variable is the encoding specified by a magic comment inside an eval"
  fails "The __ENCODING__ pseudo-variable is the evaluated strings's one inside an eval"
  fails "The __FILE__ pseudo-variable equals the absolute path of a file loaded by a relative path" # we can't clear $LOADED_FEATURES, should be treated as readonly
  fails "The __FILE__ pseudo-variable equals the absolute path of a file loaded by an absolute path" # we can't clear $LOADED_FEATURES, should be treated as readonly
  fails "The __LINE__ pseudo-variable equals the line number of the text in a loaded file"
  fails "The alias keyword is not allowed against Fixnum or String instances"
  fails "The alias keyword on top level defines the alias on Object"
  fails "The alias keyword operates on methods defined via attr, attr_reader, and attr_accessor"
  fails "The alias keyword operates on the object's metaclass when used in instance_eval"
  fails "The break statement in a captured block from a scope that has returned raises a LocalJumpError when calling the block from a method"
  fails "The break statement in a captured block from a scope that has returned raises a LocalJumpError when yielding to the block"
  fails "The break statement in a captured block from another thread raises a LocalJumpError when getting the value from another thread" # NameError: uninitialized constant Thread
  fails "The break statement in a captured block when the invocation of the scope creating the block is still active raises a LocalJumpError when invoking the block from a method"
  fails "The break statement in a captured block when the invocation of the scope creating the block is still active raises a LocalJumpError when invoking the block from the scope creating the block"
  fails "The break statement in a captured block when the invocation of the scope creating the block is still active raises a LocalJumpError when yielding to the block"
  fails "The break statement in a lambda created at the toplevel returns a value when invoking from a block"
  fails "The break statement in a lambda created at the toplevel returns a value when invoking from a method"
  fails "The break statement in a lambda created at the toplevel returns a value when invoking from the toplevel"
  fails "The break statement in a lambda from a scope that has returned raises a LocalJumpError when yielding to a lambda passed as a block argument"
  fails "The break statement in a lambda returns from the call site if the lambda is passed as a block" # Expected ["before", "unreachable1", "unreachable2", "after"] to equal ["before", "after"]
  fails "The break statement in a lambda when the invocation of the scope creating the lambda is still active returns from the lambda" # Exception: unexpected break
  fails "The class keyword does not raise a SyntaxError when opening a class without a semicolon" # NameError: uninitialized constant ClassSpecsKeywordWithoutSemicolon
  fails "The def keyword within a closure looks outside the closure for the visibility"
  fails "The defined? keyword for a scoped constant returns nil when a constant is defined on top-level but not on the module"
  fails "The defined? keyword for a scoped constant returns nil when an undefined constant is scoped to a defined constant"
  fails "The defined? keyword for a top-level scoped constant returns nil when an undefined constant is scoped to a defined constant"
  fails "The defined? keyword for variables returns 'instance-variable' for an instance variable that has been assigned to nil"
  fails "The defined? keyword for variables returns nil for a global variable that has been read but not assigned to"
  fails "The defined? keyword for variables when a Regexp matches a String returns nil for non-captures"
  fails "The defined? keyword for variables when a String matches a Regexp returns nil for non-captures"
  fails "The if expression with a boolean range ('flip-flop' operator) allows combining two flip-flops"
  fails "The if expression with a boolean range ('flip-flop' operator) evaluates the first conditions lazily with exclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) evaluates the first conditions lazily with inclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) evaluates the second conditions lazily with exclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) evaluates the second conditions lazily with inclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) keeps flip-flops from interfering"
  fails "The if expression with a boolean range ('flip-flop' operator) mimics a sed conditional with a many-element exclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) mimics a sed conditional with a zero-element exclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) mimics an awk conditional with a many-element inclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) mimics an awk conditional with a single-element inclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) scopes state by flip-flop"
  fails "The next statement in a method is invalid and raises a SyntaxError"
  fails "The or operator has a lower precedence than 'next' in 'next true or false'"
  fails "The predefined global constants includes TOPLEVEL_BINDING"
  fails "The redo statement in a method is invalid and raises a SyntaxError"
  fails "The redo statement triggers ensure block when re-executing a block"
  fails "The rescue keyword only accepts Module or Class in rescue clauses" # RuntimeError: error
  fails "The rescue keyword only accepts Module or Class in splatted rescue clauses" # RuntimeError: error
  fails "The retry keyword inside a begin block's rescue block causes the begin block to be executed again"
  fails "The retry statement raises a SyntaxError when used outside of a begin statement"
  fails "The retry statement re-executes the closest block"
  fails "The super keyword calls the correct method when the method visibility is modified"
  fails "The super keyword passes along modified rest args when they were originally empty"
  fails "The super keyword passes along modified rest args when they weren't originally empty"
  fails "The super keyword uses given block even if arguments are passed explicitly"
  fails "The super keyword when using keyword arguments passes any given keyword arguments including optional and required ones to the parent"
  fails "The super keyword without explicit arguments passes arguments and rest arguments including any modifications"
  fails "The super keyword without explicit arguments passes optional arguments that have a default value but were modified"
  fails "The super keyword without explicit arguments passes optional arguments that have a default value"
  fails "The super keyword without explicit arguments passes optional arguments that have a non-default value but were modified"
  fails "The super keyword without explicit arguments passes rest arguments including any modifications"
  fails "The super keyword without explicit arguments that are '_' including any modifications" # Expected [1, 2] to equal [14, 2]
  fails "The unpacking splat operator (*) when applied to a BasicObject coerces it to Array if it respond_to?(:to_a)" # NoMethodError: undefined method `respond_to?' for BasicObject
  fails "The until expression restarts the current iteration without reevaluating condition with redo"
  fails "The until modifier restarts the current iteration without reevaluating condition with redo"
  fails "The until modifier with begin .. end block evaluates condition after block execution"
  fails "The until modifier with begin .. end block restart the current iteration without reevaluting condition with redo"
  fails "The until modifier with begin .. end block runs block at least once (even if the expression is true)"
  fails "The until modifier with begin .. end block skips to end of body with next"
  fails "The while expression stops running body if interrupted by break in a begin ... end element op-assign value"
  fails "The while expression stops running body if interrupted by break in a parenthesized element op-assign value"
  fails "The while modifier with begin .. end block evaluates condition after block execution"
  fails "The while modifier with begin .. end block restarts the current iteration without reevaluting condition with redo"
  fails "The while modifier with begin .. end block runs block at least once (even if the expression is false)"
  fails "The while modifier with begin .. end block skips to end of body with next"
  fails "The yield call taking a single argument yielding to a lambda should not destructure an Array into multiple arguments" # Expected ArgumentError but no exception was raised ([1, 2] was returned)
  fails "The yield call taking no arguments ignores assignment to the explicit block argument and calls the passed block"
  fails "self in a metaclass body (class << obj) raises a TypeError for numbers"
  fails "self in a metaclass body (class << obj) raises a TypeError for symbols"
  fails_badly "The while expression stops running body if interrupted by break in a begin ... end attribute op-assign-or value"
  fails_badly "The while expression stops running body if interrupted by break in a parenthesized attribute op-assign-or value"
  fails_badly "The while expression stops running body if interrupted by break with unless in a parenthesized attribute op-assign-or value"
  fails_badly "The while expression stops running body if interrupted by break with unless in a begin ... end attribute op-assign-or value"
end
