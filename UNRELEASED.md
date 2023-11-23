<!--
### Added
### Removed
### Deprecated
### Performance
-->

### Changed
- Use of `JS` constant is now deprecated. The constant has been renamed to `Opal::Raw`. Throw a warning if such a constant is in use (#2525)

### Fixed
- `String#chars`: Fix iteration over out-of-BMP characters (#2620)
- Fix `Array#include?` to respect nil return value (#2661)
- Fix `opal-build` command line utility for newer Ruby versions (#2675)
- Depend on `base64` gem for Ruby 3.4 compatibility (#2652)

### Internal
- Ensure we default to later Ruby versions in CI (#2624)
- Unassorted CI/Rubocop/testing system changes (#2676, #2654, #2644, #2631, #2627, #2626)

