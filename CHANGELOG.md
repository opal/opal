## edge

*   Fix parsing of escapes in single-strings ('foo\n'). Only ' and \
    characters now get escaped in single quoted strings. Also, more escape
    sequences in double-quoted strings are now supported: `\a`, `\v`, `\f`,
    `\e`, `\s`, octal (`\314`), hex (`\xff`) and unicode (`\u1234`).

*   Sourcemaps revamp. Lexer now tracks column and line info for ever token to
    produce much more accurate sourcemaps. All method calls are now located on
    the correct source line, and multi-line xstrings are now split to generate
    a map line-to-line for long inline javascript parts.

*   Merged sprockets support from `opal-sprockets` directly into Opal. For the
    next release, the exernal `opal-sprockets` gem is no longer needed. This
    commit adds `Opal::Processor`, `Opal::Server` and `Opal::Environment`.

*   Introduce pre-processed if directives to hide code from Opal. Two special
    constant checks now take place in the compiler. Either `RUBY_ENGINE` or
    `RUBY_PLATFORM` when `== "opal"`. Both if and unless statements can pick
    up these logic checks:

        if RUBY_ENGINE == "opal"
          # this code compiles
        else
          # this code never compiles
        end

    Unless:

        unless RUBY_ENGINE == "opal"
          # this code never compiles
        end

    This is particularly useful for avoiding `require()` statements being
    picked up, which are included at compile time.

*   Add special `debugger` method to compiler. Compiles down to javascript
    `debugger` keyword to start in-browser debug console.

*   Add missing string escapes to `read_escape` in lexer. Now most ruby escape
    sequences are properly detected and handled in string parsing.

*   Disable escapes inside x-strings. This means no more double escaping all
    characters in x-strings and backticks. (`\n` => `\n`).

*   Add `time.rb` to stdlib and moved `Time.parse()` and `Time.iso8601()`
    methods there.

*   `!` is now treated as a unary method call on the object. Opal now parsed
    `!` as a def method name, and implements the method on `BasicObject`,
    `NilClass` and `Boolean`.

*   Fixed bug where true/false as object literals from javascript were not
    correctly being detected as truthy/falsy respectively. This is due to the
    javascript "feature" where `new Boolean(false) !== false`.

*   Moved `native.rb` to stdlib. Native support must now be explicitly required
    into Opal. `Native` is also now a module, instead of a top level class.
    Also added `Native::Object#respond_to?`.

*   Remove all core `#as_json()` methods from `json.rb`. Added them externally
    to `opal-activesupport`.

*   `Kernel#respond_to?` now calls `#respond_to_missing?` for compliance.

*   Fix various `String` methods and add relevant rubyspecs for them. `#chars`,
    `#to_f`, `#clone`, `#split`.

*   Fix `Array` method compliance: `#first`, `#fetch`, `#insert`, `#delete_at`,
    `#last, `#splice`, `.try_convert`.

*   Fix compliance of `Kernel#extend` and ensure it calls `#extended()` hook.

*   Fix bug where sometimes the wrong regexp flags would be generated in the
    output javascript.

*   Support parsing `__END__` constructs in ruby code, inside the lexer. The
    content is gathered up by use of the parser. The special constant `DATA`
    is then available inside the ruby code to read the content.

*   Support single character strings (using ? prefix) with escaped characters.

*   Fix lexer to detect dereferencing on local variables even when whitespace
    is present (`a = 0; a [0]` parses as a deference on a).

*   Fix various `Struct` methods. Fixed `#each` and `#each_pair` to return
    self. Add `Struct.[]` as synonym for `Struct.new`.

*   Implemented some `Enumerable` methods: `#collect_concat`, `#flat_map`,
    `#reject`, `#reverse_each`, `#partition` and `#zip`.

## 0.5.5 2013-11-25

*   Fix regression: add `%i[foo bar]` style words back to lexer

*   Move corelib from `opal/core` to `opal/corelib`. This stops files in
    `core/` clashing with user files.

## 0.5.4 2013-11-20

*   Reverted `RUBY_VERSION` to `1.9.3`. Opal `0.6.0` will be the first release
    for `2.0.0`.

## 0.5.3 2013-11-12

*   Opal now targets ruby 2.0.0

*   Named function inside class body now generates with `$` prefix, e.g.
    `$MyClass`. This makes it easier to wrap/bridge native functions.

*   Support Array subclasses

*   Various fixes to `String`, `Kernel` and other core classes

*   Fix `Method#call` to use correct receiver

*   Fix `Module#define_method` to call `#to_proc` on explicit argument

*   Fix `super()` dispatches on class methods

*   Support `yield()` calls from inside a block (inside a method)

*   Cleanup string parsing inside lexer

*   Cleanup parser/lexer to use `t` and `k` prefixes for all tokens

## 0.5.2 2013-11-11

*   Include native into corelib for 0.5.x

## 0.5.1 2013-11-10

*   Move all corelib under `core/` directory to prevent filename clashes with
    `require`

*   Move `native.rb` into stdlib - must now be explicitly required

*   Implement `BasicObject#__id__`

*   Cleanup and fix various `Enumerable` methods

## 0.5.0 2013-11-03

*   WIP: https://gist.github.com/elia/7747460

## 0.4.2 2013-07-03

*   Added `Kernel#rand`. (fntzr)

*   Restored the `bin/opal` executable in gemspec.

*   Now `.valueOf()` is used in `#to_n` of Boolean, Numeric, Regexp and String
    to return the naked JavaScript value instead of a wrapping object.

*   Parser now wraps or-ops in paranthesis to stop variable order from
    leaking out when minified by uglify. We now have code in this
    format: `(((tmp = lhs) !== false || !==nil) ? tmp : rhs)`.

## 0.4.1 2013-06-16

*   Move sprockets logic out to external opal-sprockets gem. That now
    handles the compiling and loading of opal files in sprockets.

## 0.4.0 2013-06-15

*   Added fragments to parser. All parser methods now generate one or
    more Fragments which store the original sexp. This allows us to
    enumerate over them after parsing to map generated lines back to
    original line numbers.

*   Reverted `null` for `nil`. Too buggy at this time.

*   Add Opal::SprocketsParser as Parser subclass for handling parsing
    for sprockets environment. This subclass handles require statements
    and stores them for sprockets to use.

*   Add :irb option to parser to keep top level lvars stored inside
    opal runtime so that an irb session can be persisted and maintain
    access to local variables.

*   Add Opal::Environment#use_gem() helper to add a gem to opals load
    path.

*   Stop pre-setting ivars to `nil`. This is no longer needed as `nil`
    is now `null` or `undefined`.

*   Use `null` as `nil` in opal. This allows us to send methods to
    `null` and `undefined`, and both act as `nil`. This makes opal a
    much better javascript citizen. **REVERTED**

*   Add Enumerable#none? with specs.

*   Add Opal.block_send() runtime helper for sending methods to an
    object which uses a block.

*   Remove \_klass variable for denoting ruby classes, and use
    constructor instead. constructor is a javascript property used for
    the same purpose, and this makes opal fit in as a better js citizen.

*   Add Class.bridge\_class method to bridge a native constructor into an
    opal class which will set it up with all methods from Object, as
    well as giving it a scope and name.

*   Added native #[]= and #to_h methods, for setting properties and
    converting to a hash respectivaly.

*   Fix bug where '::' was parsed as :colon2 instead of :colon3 when in
    an args scope. Fixes #213

*   Remove lots of properties added to opal classes. This makes normal
    js constructors a lot closer to opal classes, making is easier to
    treat js classes as opal classes.

*   Merge Hash.from_native into Hash.new

## 0.3.44 2013-05-31

*   Cleanup runtime, and remove various flags and functions from opal
    objects and classes (moving them to runtime methods).

*   Remove some activesupport methods into external lib.

*   Add/fix lots of String methods, with specs.

*   Add more methods to MatchData class.

*   Implement $' and $` variables.

*   Opal can now call methods on all native objects, via method missing
    dispatcher.

*   Add Opal::Environment as custom sprockets subclass which adds all
    opal load paths automatically.

## 0.3.43 2013-05-02

*   Stop inlining respond_to? inside the parser. This now fully respects
    an object overriding respond_to?.

*   Expose `Opal.eval()` function when parser is loaded for parsing
    and running strings of ruby code.

*   Add erb to corelib (as well as compiler to gem lib). ERB files with
    .opalerb extension will automatically be compiled into Template
    constant.

*   Added some examples into examples/ dir.

*   Add Opal.send() javascript function for sending methods to ruby
    objects.

*   Native class for wrapping and interacting with native objects and
    function calls.

*   Add local_storage to stdlib as a basic wrapper around localStorage.

*   Make method_missing more performant by reusing same dispatch function
    instead of reallocating one for each run.

*   Fix Kernel#format to work in firefox. String.prototype.replace() had
    different semantics for empty matching groups which was breaking
    Kernel#format.

## 0.3.42 2013-03-21

*   Fix/add lots of language specs.

*   Seperate sprockets support out to opal-sprockets gem.

*   Support %r[foo] style regexps.

*   Use mspec to run specs on corelib and runtime. Rubyspecs are now
    used, where possible to be as compliant as possible.

## 0.3.41 2013-02-26

*   Remove bin/opal - no longer required for building sources.

*   Depreceate Opal::Environment. The Opal::Server class provides a better
    method of using the opal load paths. Opal.paths still stores a list of
    load paths for generic sprockets based apps to use.

## 0.3.40 2013-02-23

*   Add Opal::Server as an easy to configure rack server for testing and
    running Opal based apps.

*   Added optional arity check mode for parser. When turned on, every method
    will have code which checks the argument arity. Off by default.

*   Exception subclasses now relfect their name in webkit/firefox debuggers
    to show both their class name and message.

*   Add Class#const_set. Trying to access undefined constants by a literal
    constant will now also raise a NameError.

## 0.3.39 2013-02-20

*   Fix bug where methods defined on a parent class after subclass was defined
    would not given subclass access to method. Subclasses are now also tracked
    by superclass, by a private '_inherited' property.

*   Fix bug where classes defined by `Class.new` did not have a constant scope.

*   Move Date out of opal.rb loading, as it is part of stdlib not corelib.

*   Fix for defining methods inside metaclass, or singleton_class scopes.

## 0.3.38 2013-02-13

*   Add Native module used for wrapping objects to forward calls as native
    calls.

*   Support method_missing for all objects. Feature can be enabled/disabled on
    Opal::Processor.

*   Hash can now use any ruby object as a key.

*   Move to Sprockets based building via `Opal::Processor`.
