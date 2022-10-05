<!--
### Internal
### Changed
### Added
### Removed
### Deprecated
### Performance
### Fixed
-->

### Added

- Add CLI support for ESM, at least for Chrome, NodeJS, QuickJS and GJS (#2435)
- Support exit in Chrome CLI Runner, both sync and async (#2439)
- Make sure the Server CLI Runner can pick up changes in sources (#2436)

### Fixed

- Fix an edge case of if in the most complex form not returning (#2433)
- `String#length` is now available when using `opal/mini` (#2438)

### Internal

- GitHub Workflows security hardening (#2432)
