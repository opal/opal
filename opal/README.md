# Opal corelib

This is the Opal corelib implementation API documentation.
The whole corelib is loaded upon `require 'opal'`.

The `runtime.js` documentation is [available here](http://opalrb.org/docs/api/master/corelib/file.RUNTIME.html) (in master)

# Cherry-picking

Note that `require 'opal'` will load all of the corelib, which is likely to
have a ton of stuff you don't need.

If you're concerned about runtime size, you can `require 'opal/base'` and
require anything you need, or `require 'opal/mini'` to have a working Ruby
without *useless* stuff.
