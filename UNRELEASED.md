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

- Add safari runner (#2513)

### Fixed

- Fix CLI file reading for macOS (#2510)
- Make Date/Time.parse on Firefox more compatible with Chrome and Ruby (#2506)
- Safari/WebKit can now parse code compiled with lookbehind regexps, failing at runtime instead (#2511)
- Fix `--watch` ignoring some directories (e.g. `tmp`) (#2509)
- Fix rake dist not generating libraries correctly for the CDN (#2515)
- Prefork: output processed files in a correct, deterministic order (#2516)
- Fix the handling of ARGV for the opal executable (#2518)

### Internal

- Platform specific spec filters (#2508)
- Run Firefox specs by default (#2507)
- Run Safari specs by default (#2513)
- [mspec_opal] Avoid lookbehind Regexp for compatibility with various javascript engines (#2512)
