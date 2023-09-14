<!--
### Internal
### Changed
### Added
### Removed
### Deprecated
### Performance
-->

### Fixed

- Use a Map instead of a POJO for the jsid_cache (#2584)
- Lowercase response headers in `SimpleServer` for rack 3.0 compatibility (#2578)
- Fix `switch` with Object-wrapped values (#2542)
- Regexp.escape: Cast to String or drop exception (#2552)
- Chrome runner fix: support code that contains `</script>` (#2581)
