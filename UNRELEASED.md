<!--
### Internal
### Changed
### Added
### Removed
### Deprecated
-->

### Performance

- Optimize `Hash#rehash` for the common case, avoid calling `$slice` when no hash collision is present (#2571)

### Fixed

- `String#{r,l,}strip`: Make them work like in MRI for non-breaking white-space (#2612)
- Compat regression fix: `Hash#to_n` should return a JS object (#2613)
