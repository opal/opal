### Added

- Basic support for `uplevel:` keyword argument in `Kernel#warn` (#2006)
- Added a `#respond_to_missing?` implementation for `BasicObject`, `Delegator`, `OpenStruct`, that's meant for future support in the Opal runtime, which currently ignores it (#2007)
- `Opal::Compiler#magic_comments` that allows to access magic-comments format and converts it to a hash (#2038)
- Use magic-comments to declare helpers required by the file (#2038)
- `Opal.$$` is now a shortcut for `Opal.const_get_relative` (#2038)
- `Opal.$$$` is now a shortcut for `Opal.const_get_qualified` (#2038)
- Added support for `globalThis` as the generic global object accessor (#2047)
- `Opal::Compiler#magic_comments` that allows to access magic-comments format and converts it to a hash
- Use magic-comments to declare helpers required by the file
- `Opal.$$` is now a shortcut for `Opal.const_get_relative`
- `Opal.$$$` is now a shortcut for `Opal.const_get_qualified`
- Source-map support for Node.js in the default runner (#2045)
- SecureRandom#hex(n) (#2050)
- Added a generic implementation of Kernel#caller and #warn(uplevel:) that works with sourcemaps in Node.js and Chrome (#2065)
- Added support for numblocks `-> { _1 + _2 }.call(3, 4) # => 7` (#2149)
- Support `<internal:…>` and `<js:…>` in stacktraces, like MRI we now distinguish internal lines from lib/app lines (#2154)

### Fixed

- Time#strftime %j should be padded to width 3
- Array#delete_if (#2069)
- Array#keep_if (#2069)
- Array#reject! (#2069)
- Array#select! (#2069)
- Struct#dup (#1995)
- Integer#gcdlcm (#1972)
- Enumerable#to_h (#1979)
- Enumerator#size (#1980)
- Enumerable#min (#1982)
- Enumerable#min_by (#1985)
- Enumerable#max_by (#1985)
- Set#intersect? (#1988)
- Set#disjoint? (#1988)
- Set#keep_if (#1987)
- Set#select! (#1987)
- Set#reject! (#1987)
- Module#alias_method (#1983)
- Enumerable#minmax_by (#1981)
- Enumerator#each_with_index (#1990)
- Range#== (#1992)
- Range#each (#1991)
- Enumerable#zip (#1986)
- String#getbyte (#2141)
- Struct#dup not copying `$$data` (#1995)
- Fixed usage of semicolon in single-line backticks (#2004)
- Module#attr with multiple arguments (#2003)
- `PathReader` used to try to read missing files instead of respecting the `missing_require_severity` configuration value (#2044)
- Removed some unused variables from the runtime (#2052)
- Fixed a typo in the runtime (#2054)
- Fix Regexp interpolation, previously interpolating with other regexps was broken (#2062)
- Set match on StringScanner#skip and StringScanner#scan_until (#2061)
- Fix ruby 2.7 warnings (#2071)
- Improve the --help descriptions (#2146)
- Remove BasicObject#class (#2166)
- Time#strftime %j leading zeros (#2161)

### Changed

- Updated outdated parser version (#2013)
- Nashorn has been deprecated but GraalVM still supports it (#1997)
- "opal/mini" now includes "opal/io" (#2002)
- Regexps assigned to constants are now frozen (#2007)
- `Opal.$$` changed from being the constant cache of Object to being a shortcut for `Opal.const_get_relative` (#2038)
- Moved REPL implementation from bin/ to its own lib/ file as `opal/repl.rb` (#2048)
- `Encoding.default_external` is now initialized with `__ENCODING__` (#2072)
- Keep the MersenneTwister implementation private (#2108)
- Change parser to 3.0 (#2148)
- Fix forwarding a rescued error to a global var: `rescue => $gvar` (#2154)
- Now using Parser v3.0 and targeting Ruby 3.0 (#2156)

### Deprecated

- Requiring nodejs/stacktrace has been deprecated, source-maps are already
  supported by the default Node.js runner or by requiring https://github.com/evanw/node-source-map-support
  before loading code compiled by Opal (#2045)

### Removed

- Removed special compilation for the `Opal.truthy?` and `Opal.falsy?` helpers (#2076)
