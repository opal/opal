
- Support for multiple arguments in Hash#{merge, merge!, update} (#2187)
- Support for Ruby 3.0 forward arguments: `def a(...) puts(...) end` (#2153)
- Support for beginless and endless ranges: `(1..)`, `(..1)` (#2150)
- Preliminary support for `**nil` argument - see #2240 to note limitations (#2152)
- Support for `Random::Formatters` which add methods `#{hex,base64,urlsafe_base64,uuid,random_float,random_number,alphanumeric}` to `Random` and `SecureRandom` (#2218)
- Basic support for ObjectSpace finalizers and ObjectSpace::WeakMap (#2247)
- A more robust support for encodings (especially binary strings) (#2235)
- Support for `"\x80"` syntax in String literals (#2235)
- Added `String#+@`, `String#-@` (#2235)
- Support for `begin <CODE> end while <CONDITION>` (#2255)
- Added Hash#except and `Hash#except!` (#2243)
- Parser 3.0: Implement pattern matching (as part of this `{Array,Hash,Struct}#{deconstruct,deconstruct_keys} methods were added)` (#2243)
- [experimental] Reimplement Promise to make it bridged with JS native Promise, this new implementation can be used by requiring `promise/v2` (#2220)


### Fixed

- Encoding lookup was working only with uppercase names, not giving any errors for wrong ones (#2181, #2183, #2190)
- Fix `Number#to_i` with huge number (#2191)
- Add regexp support to `String#start_with` (#2198)
- `String#bytes` now works in strict mode (#2194)
- Fix nested module inclusion (#2053)
- SecureRandom is now cryptographically secure on most platforms (#2218, #2170)
- Fix performance regression for `Array#unshift` on v8 > 7.1 (#2116)
- String subclasses now call `#initialize` with multiple arguments correctly (with a limitation caused by the String immutability issue, that a source string must be the first argument and `#initialize` can't change its value) (#2238, #2185)
- Number#step is moved to Numeric (#2100)
- Fix class Class < superclass for invalid superclasses (#2123)
- Fix `String#unpack("U*")` on binary strings with latin1 high characters, fix performance regression on that call (#2235, #2189, #2129, #2099, #2094, #2000, #2128)
- Fix `String#to_json` output on some edge cases (#2235)
- Rework class variables to support inheritance correctly (#2251)
- ISO-8859-1 and US-ASCII encodings are now separated as in MRI (#2235)
- `String#b` no longer modifies object strings in-place (#2235)
- Parser::Builder::Default.check_lvar_name patch (#2195)

### Changed

- `String#unpack`, `Array#pack`, `String#chars`, `String#length`, `Number#chr`, and (only partially) `String#+` are now encoding aware (#2235)
- `String#inspect` now uses `\x` for binary stirngs (#2235)
- `if RUBY_ENGINE == "opal"` and friends are now outputing less JS code (#2159, #1965)
- `Array`: `to_a`, `slice`/`[]`, `uniq`, `*`, `difference`/`-`, `intersection`/`&`, `union`/`|`, flatten now return Array, not a subclass, as Ruby 3.0 does (#2237)
- `Array`: `difference`, `intersection`, `union` now accept multiple arguments (#2237)

### Deprecated

- Stopped testing Opal on Ruby 2.5 since it reached EOL.

### Removed

- Removed support for the outdated `c_lexer`, it was optional and didn't work for the last few releases of parser (#2235)
