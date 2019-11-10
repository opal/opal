<!--
Whitespace conventions:
- 4 spaces before ## titles
- 2 spaces before ### titles
- 1 spaces before normal text
-->

### Added

- Basic support for `uplevel:` keyword argument in `Kernel#warn` (#2006)
- Added a `#respond_to_missing?` implementation for `BasicObject`, `Delegator`, `OpenStruct`, that's meant for future support in the Opal runtime, which currently ignores it (#2007)
- `Opal::Compiler#magic_comments` that allows to access magic-comments format and converts it to a hash

### Fixed

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
- Struct#dup not copying `$$data` (#1995)
- Fixed usage of semicolon in single-line backticks (#2004)
- Module#attr with multiple arguments (#2003)


### Changed

- Updated outdated parser version (#2013)
- Nashorn has been deprecated but GraalVM still supports it (#1997)
- "opal/mini" now includes "opal/io" (#2002)
- Regexps assigned to constants are now frozen (#2007)

