### Internal

- Improve performance of argument coertion, fast-track `Integer`, `String`, and calling the designed coertion method (#2383)
- Optimize `Array#[]=` by moving the implementation to JavaScript and inlining type checks (#2383)
- Optimize internal runtime passing of block-options (#2383)

### Fixed

- Fix `Regexp.new`, previously `\A` and `\z` didn't match beginning and end of input (#2079)

<!--
### Internal
### Changed
### Added
### Removed
### Deprecated
-->
