<!--
### Internal
### Added
### Removed
### Deprecated
### Performance
### Fixed
-->

### Compatibility

- Add a magic-comment that will disable x-string compilation to JavaScript (#2543)

### Fixed

- Fix `Kernel#Float` with `exception:` option (#2532)
- Fix `Kernel#Integer` with `exception:` option (#2531)
- Fix `String#split` with limit and capturing regexp (#2544)
- Fix `switch` with Object-wrapped values (#2542)
- Fix non-direct subclasses of bridged classes not calling the original constructor (#2546)
- Regexp.escape: Cast to String or drop exception (#2552)
- Propagate removal of method from included/prepended modules (#2553)
- Restore `nodejs/yaml` functionality (#2551)

### Added

- SourceMap support for `Kernel#eval` (#2534)

### Changed

- Change compilation of Regexp nodes that may contain advanced features, so if invalid that they would raise at runtime, not parse-time (#2548)

### Internal

- Update rubocop (#2535)

### Performance

- Improve performance of `Array#intersect?` and `#intersection` (#2533)

### Deprecated

- Deprecate using x-string to access JavaScript without an explicit magic-comment (#2543)


