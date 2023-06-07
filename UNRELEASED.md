<!--
### Internal
### Added
### Removed
### Deprecated
### Performance
### Fixed
-->

### Fixed

- Fix `Kernel#Float` with `exception:` option (#2532)
- Fix `Kernel#Integer` with `exception:` option (#2531)

### Added

- SourceMap support for `Kernel#eval` (#2534)

### Changed

- Change compilation of Regexp nodes that may contain advanced features, so if invalid that they would raise at runtime, not parse-time (#2548)

### Internal

- Update rubocop (#2535)

