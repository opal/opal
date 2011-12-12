Opal Tests
==========

All tests/specs in this folder should be run in an opal context, either
with the bundled buidl tools, or directly in the browser.

### Running from the source directory.

If you have cloned this repo, and have run `opal install` to install
`opal-test` into vendor/opal/opal-test, then any test can be run with:

```
bin/opal spec/core/array/first_spec.rb
```

This will run all tests for `Array#first`. Of course, you might need to
add the opal lib to your path like the following:

```
ruby -I ./lib bin/opal spec/core/array/first_spec.rb
```

License
=======

All specs/tests are taken from rubyspec. Original license:

Copyright (c) 2008 Engine Yard, Inc. All rights reserved.

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

