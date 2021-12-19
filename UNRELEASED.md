### Added

- Implement `chomp:` option for `String#each_line` and `#lines` (#2355)

### Fixed

- Fix defining multiple methods with the same block (#2345)
- Fix coertion for `Array#drop` (#2371)
- Fix coertion for `File.absolute_path` (#2372)
- Fix some `IO#puts` edge cases (no args, empty array, nested array, …) (#2372)
- Preserve UNC path prefix on File.join (#2366)
- Methods on `Kernel`, `BasicObject`, `Boolean` will never return boxed values anymore (#2293)
  - `false.tap{}` will now correctly return a JS value of `false`, not `Object(false)`

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
