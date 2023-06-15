<!--
### Internal
### Added
### Removed
### Deprecated
### Performance
### Fixed
### Documentation
-->

### Deprecated

- Deprecate using x-string to access JavaScript without an explicit magic-comment (#2543)

### Compatibility

- Add a magic-comment that will disable x-string compilation to JavaScript (#2543)

### Fixed

- Fix `Kernel#Float` with `exception:` option (#2532)
- Fix `Kernel#Integer` with `exception:` option (#2531)
- Fix `String#split` with limit and capturing regexp (#2544)
- Fix `switch` with Object-wrapped values (#2542)
- Fix non-direct subclasses of bridged classes not calling the original constructor (#2546)
- Regexp.escape: Cast to String or drop exception (#2552)
- Propagate removal of method from included/prepended modules (#2553)
- Restore `nodejs/yaml` functionality (#2551)
- Fix sine `Range#size` edge cases (#2541)

### Added

- SourceMap support for `Kernel#eval` (#2534)

### Changed

- Change compilation of Regexp nodes that may contain advanced features, so if invalid that they would raise at runtime, not parse-time (#2548)

### Documentation

- Bridging documentation (#2541) 

### Performance

- Improve performance of `Array#intersect?` and `#intersection` (#2533)
- Proc#call: Refactor for performance (#2541) 
- Opal.stub_for: optimize (#2541) 
- Hash: Optimize #to_a (#2541) 
- Array: Optimize #collect/#map (#2541)

### Internal

- Update rubocop (#2535)
- Match3Node Cleanup (#2541) 
- IFlipFlop/EFlipFlop: Refactor for readability (#2541) 
- ForRewriter: Refactor for readability (#2541) 
