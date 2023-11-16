<!--
### Internal
### Changed
### Added
### Removed
### Deprecated
### Performance
### Fixed
-->

### Performance

- Optimize `Hash#rehash` for the common case, avoid calling `$slice` when no hash collision is present (#2571)

### Fixed

- `String#{r,l,}strip`: Make them work like in MRI for non-breaking white-space (#2612)

### Internal

- Bump the ECMA version from 3 to 12 for ESLint (#2537)
