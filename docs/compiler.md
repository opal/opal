# Opal Compiler

Opal is a source to source compiler. It accepts ruby code as a string and
generates javascript code which can be run in any environment. Generated
code relies on the opal runtime which provides the class system and some
other runtime helpers.

## Compiler stages

The compiler can be broken down into 3 separate stages:

* lexing/parsing
* code generation

### Lexer/Parser

The [opal parser][parser] relies on the `parser` gem, see debug/development documentation there to know more about its internals: https://whitequark.github.io/parser/.

### Code generation

The [opal compiler][compiler] takes these sexps from the parser
and generates ruby code from them. Each type of sexp has [its own node type][base-node]
used to generate javascript. Each node creates an array of one or more
[fragments][fragments] which are the concatenated together to
form the final javascript. Fragments are used as they contain the generated
code as well as a reference back to the original sexp which is useful for
generating source maps afterwards.


[sexps]: https://github.com/opal/opal/tree/master/lib/opal/parser/sexp.rb
[compiler]: https://github.com/opal/opal/tree/master/lib/opal/compiler.rb
[fragments]: https://github.com/opal/opal/tree/master/lib/opal/fragment.rb
[base-node]: https://github.com/opal/opal/tree/master/lib/opal/nodes/base.rb
