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

- Update benchmarking and CLI runners, added support for Deno and Firefox (#2490, #2492, #2494, #2495, #2497, #2491, #2496) 
- Ruby 3.2 support branch (#2500)
- Added `--watch` and `--output` options to the CLI for live compilation (#2485)

### Performance

- Replace all occurences of `'$'+name` with a cached helper, saving about 2% in performance (#2481)
- Optimize argument passing and arity checks (#2499)
- Targeted patches for Opal-Parser, saves up to 12% during compilation (#2482)

### Internal

- MSpec & Ruby Spec update (#2486)

### Fixed

- Remove throws from runtime (#2484)
