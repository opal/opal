### Added

- Implement `chomp:` option for `String#each_line` and `#lines` (#2355)
- Ruby 3.1 support and some older Ruby features we missed (#2347)
  - Use parser in 3.1 mode to support new language-level features like hashes/kwargs value omission, the pin operator for pattern matching
  - `Array#intersect?`
  - `String#strip` and `String#lstrip` to also remove NUL bytes
  - `Integer.try_convert`
  - `public`, `private`, `protected`, `module_function` now return their arguments
  - `Class#descendants`, `Class#subclasses`
  - (<=1.8) `Kernel#local_variables`
  - (<=2.3) Set local variables for regexp named captures (`/(?<b>a)/ =~ 'a'` => `b = 'a'`)
  - Remove deprecated `NIL`, `TRUE`, `FALSE` constants
  - `String#unpack` and `String#unpack1` to support an `offset:` kwarg
  - `MatchData#match`, `MatchData#match_length`
  - Enumerable modernization
    - `Enumerable#tally` to support an optional hash accumulator
    - `Enumerable#each_{cons,slice}` to return self
    - `Enumerable#compact`
  - `Refinement` becomes its own class now
  - `Struct#keyword_init?`
  - (pre-3.1) Large Enumerator rework
    - Introduce `Enumerator::ArithmeticSequence`
    - Introduce `Enumerator::Chain`
    - Introduce `Enumerator#+` to create `Enumerator::Chain`s
    - `Enumerator#{rewind,peek,peek_values,next,next_values}`
    - Improve corelib support for beginless/endless ranges and `ArithmeticSequences`
      - `String#[]`, `Array#[]`, `Array#[]=`, `Array#fill`, `Array#values_at`
    - `Range#step` and `Numeric#step` return an `ArithmeticSequence` when `Numeric` values are in play
    - Introduce `Range#%`
    - `Enumerator::Yielder#to_proc`
    - Fix #2367
  - (2.7) `UnboundMethod#bind_call`
  - (Opal) `{Kernel,BasicObject}#{inspect,p,pp,method_missing}` may work with JS native values now, also they now correctly report cycles
  - `Enumerable#sum` uses Kahan's summation algorithm to reduce error with floating point values
  - `File.dirname` supports a new `level` argument
- Vendor in `optparse` and `shellwords` (#2326)
- Preliminary support for compiling the whole `bin/opal` with Opal (#2326)

### Fixed

- Fix defining multiple methods with the same block (#2345)
- Fix coertion for `Array#drop` (#2371)
- Fix coertion for `File.absolute_path` (#2372)
- Fix some `IO#puts` edge cases (no args, empty array, nested array, …) (#2372)
- Preserve UNC path prefix on File.join (#2366)
- Methods on `Kernel`, `BasicObject`, `Boolean` will never return boxed values anymore (#2293)
  - `false.tap{}` will now correctly return a JS value of `false`, not `Object(false)`
- opal-parser doesn't break on `<<~END` strings anymore (#2364)
- Fix error reporting at the early stage of loading (#2326)

### Changed

- Various outputted code size optimizations - 19% improvement for minified unmangled AsciiDoctor bundle - see: https://opalrb.com/blog/2021/11/24/optimizing-opal-output-for-size/ (#2356)
- Second round of code size optimizations - 3% improvement for AsciiDoctor bundle on top of the first round - 23% total - see: https://github.com/opal/opal/pull/2365/commits (#2365)
  - The calls to `==`, `!=` and `===` changed their semantics slightly: it's impossible to monkey patch those calls for `String` and `Number`, but on other classes they can now return `nil` and it will be handled correctly
  - The calls to `!` changed their semantics slightly: it's impossible to monkey patch this call for `Boolean` or `NilClass`.


<!--
### Deprecated
### Removed
### Internal
-->
