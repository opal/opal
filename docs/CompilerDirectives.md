# Compiler Directives

The Opal compiler supports some special directives that can optimize or
enhance the output of compiled ruby code to suit the ruby environment.

## Require Directive

All calls to `require` are captured so that the compiler and build tools
can determine which dependencies a file has. In the case of `Builder`,
these are collated and then added to a list of files to be processed.

### `require`

Assuming we have a file `foo.rb`:

    # foo.rb
    require 'bar'
    require 'baz'

The compiler will collect these two dependencies, and then `Builder`
will attempt to discover them within the opal load path to also compile
them into the target output. If these dependencies cannot be resolved,
then a compile time error will be thrown.

#### Dynamic Requires

Opal only supports hard-coded requires. This means that any dynamically
generated require statemnts cannot be discoeverd. Opal may raise an
error or just produce a warning if a dynamic require is used. A dynamic
require is any require that cannot be resolved using static analysis. A
common use case of dynamic requires is to include a directory of ruby
files. In this case, see `require_tree` below.

### `require_relative`

`require_relative` is also supported by opals compiler for ahead-of-time
inclusion.

    # foo.rb
    require_relative 'bar'

This example will try to resolve `bar.rb` in the same directory.

### `autoload`

`autoload` is used to load a modules and classes within a modules
namespace. Aslong as the string argument given to `autoload` can be
resolved in Opals load paths, in the same way as `require`, then these
referenced dependencies will also be compiled.

    # foo.rb
    module Foo
      autoload :Bar, 'bar'
    end

In this example, `bar.rb` will also be required.

### `require_tree`

`require_tree` can be used as an Opal friendly alternative to globbing
over a directory to require a list of dependencies.

    # foo.rb
    require_tree './models'

This will, at compile time, resolve all files inside the `models/`
directory and also compile them to the output. At runtime this method
will then loop over all modules defined, and require them if they match
that given module path.

Note: The given directory **must** be inside Opals load path, otherwise
no files will be compiled.

### Handling non-ruby requirements

Opal's `require` method is also special as it allows non-ruby source
files to be required and generated in the output. The obvious example of
this is requiring javascript source files. Javascript sources are
treated as first class citizens in Opal. The  Opal gem also supports
compiling `.erb` files using the same process.

## Opal Specific Code Compilation

A special case `if` and `unless` statements can hide or show blocks of
code from the Opal compiler. These check against `RUBY_ENGINE` or
`RUBY_PLATFORM`. As these are valid ruby statements against constants
that exist in all ruby runtimes, they will not affect any running code:

    if RUBY_ENGINE == 'opal'
      # this code compiles
    else
      # this code never compiles
    end

Unless statements are also supported:

    unless RUBY_ENGINE == 'opal'
      # this code will not run
    end

Also `!=` statements work:

    if RUBY_ENGINE != 'opal'
      puts "do not run this code"
    end

These blocks of code dont run at all at runtime, but they also never
compile so will never be in the output javascript code. This is
particularly useful for using code in both mri and Opal.

Some uses are:

  * Avoid `require` statements being picked up by Opal compile time
    require handling.

  * To stop certain requires taking place for opal (and vice-versa for
    shared libraries).

  * To wrap x-strings which might break in compiled javascript output.

  * To simply avoid compiling large blocks of code that are not needed
    in the javascript/opal version of an app.

In all these examples `RUBY_PLATFORM` can be used instead of
`RUBY_ENGINE`.
