<!--
### Internal
### Added
### Removed
### Deprecated
### Performance
### Fixed
### Documentation
-->

## Highlights

### `Hash` is now bridged to JavaScript `Map`

This change brings a lot of benefits, but also some incompatibilities. The main benefit is that `Hash` now is both more performant and relies on native JavaScript capabilities.
This improves interoperability with JavaScript. As a downside, applications reaching for internal `Hash` data structures will need to be updated.

Interacting with `Hash` from `JavaScript` is easier than ever:

```ruby
hash = `new Map([['a', 1], ['b', 2]])`
hash # => {a: 1, b: 2}
`console.log(hash)` # => Map(2) {"a" => 1, "b" => 2}
`hash.get('a')` # => 1
`hash.set('c', 3)`
hash # => {a: 1, b: 2, c: 3}
hash.keys # => ["a", "b", "c"]
hash.values # => [1, 2, 3]
```

### Performance improvements

This release brings a lot of performance improvements, our tests on Asciidoctor show a 25% improvement in performance, but we've seen up to 66% performance improvement on some applications.

## Changelog

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
- Use a Map instead of a POJO for the jsid_cache (#2584)
- Fix `String#object_id`, `String#__id__`, `String#hash` to match CRuby's behavior (#2576)
- Lowercase response headers in `SimpleServer` for rack 3.0 compatibility (#2578)
- Fix `Module#clone` and `Module#dup` to properly copy methods (#2572)
- Chrome runner fix: support code that contains `</script>` (#2581)

### Added

- SourceMap support for `Kernel#eval` (#2534)
- Add `CGI::Util#escapeURIComponent` and `CGI::Util#unescapeURIComponent` (#2566)

### Changed

- Change compilation of Regexp nodes that may contain advanced features, so if invalid that they would raise at runtime, not parse-time (#2548)
- `Hash` is now bridged to JavaScript `Map` and support for non-symbol keys in keyword arguments (#2568)

### Documentation

- Bridging documentation (#2541)
- Fix Typo in Running tests Section of README.md File (#2580)

### Performance

- Improve performance of `Array#intersect?` and `#intersection` (#2533)
- `Proc#call`: Refactor for performance (#2541)
- Opal.stub_for: optimize (#2541)
- Hash: Optimize `#to_a` (#2541)
- Array: Optimize `#collect`/`#map` (#2541)
- Optimize argument slicing in runtime for performance (#2555)
- Closure: Generate a JavaScript object, not an Error, gain up to 15% on Asciidoctor (#2556)
- Optimize `String#split` and `String#start_with` (#2560)

### Internal

- Update rubocop (#2535)
- Match3Node Cleanup (#2541)
- IFlipFlop/EFlipFlop: Refactor for readability (#2541)
- ForRewriter: Refactor for readability (#2541)
