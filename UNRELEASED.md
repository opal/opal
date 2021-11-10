### Fixed

- Update documentation (#2350)
- Fix `IO#gets` getting an extra char under some circumstances (#2349)
- Raise a `TypeError` instead of `UndefinedMethod` if not a string is passed to `__send__` (#2346)
- Do not modify `$~` when calling `String#scan` from internal methods (#2353)
- Stop interpreting falsey values as a missing constant in `Module#const_get` (#2354)

<!--
### Changed
### Deprecated
### Removed
### Internal
-->
