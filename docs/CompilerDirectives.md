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
