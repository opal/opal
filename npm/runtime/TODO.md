## TODO

- copy _nodejs.js_, _opal.js_, _pathname.js_ and _stringio.js_ from _build_ to _npm/runtime/src_
- append `export default Opal` in _opal.js_
- apply transformations on _nodejs.js_ to make it ESM-compatible (i.e., replace `require` by `import`)