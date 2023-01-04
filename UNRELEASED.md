<!--
### Internal
### Changed
### Added
### Removed
### Deprecated
### Performance
### Fixed
-->

### Fixed

- Fix CLI file reading for macOS (#2510)
- Make Date/Time.parse on Firefox more compatible with Chrome and Ruby (#2506)
- Safari/WebKit can now parse code compiled with lookbehind regexps, failing at runtime instead (#2511)

### Internal

- Platform specific spec filters (#2508)
- Run Firefox specs by default (#2507)
- [mspec_opal] Avoid lookbehind Regexp for compatibility with various javascript engines (#2512)
