<!--
### Internal
### Changed
### Added
### Removed
### Deprecated
### Performance
-->

### Fixed

- Make `Time.new` not depend on `Date.prototype.getTimezoneOffset()` (#2426)
- Fix exception during `Hash#each_value` if keys get deleted during loop (#2427)
- Fix scan_until and check_until implementation of StringScanner (#2420)
