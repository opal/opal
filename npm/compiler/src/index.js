const Opal = require('@opal/runtime').Opal
require('./opal-builder.js')
require('./opal-source-maps.js')

Opal.require('nodejs')
Opal.require('opal-builder')
Opal.require('opal-source-maps')

/**
 * Convert a JSON to an (Opal) Hash.
 * @private
 */
const toHash = function (object) {
  if (object && !object.smap) {
    return Opal.hash(object)
  }
  return object
}

const Builder = Opal.const_get_qualified(Opal.const_get_relative([], 'Opal'), 'Builder')
const ERB = Opal.const_get_qualified(Opal.const_get_relative([], 'Opal'), 'ERB')

// Public API

Builder.$$class.prototype.create = function () {
  return this.$new()
}

Builder.prototype.appendPaths = function (paths) {
  this.$append_paths(paths)
}

Builder.prototype.setCompilerOptions = function (options) {
  this.compiler_options = toHash(options)
}

Builder.prototype.build = function (path, options) {
  return this.$build(path, toHash(options))
}

Builder.prototype.buildString = function (str, path = '.', options = {}) {
  return this.$build_str(str, path, toHash(options))
}

Builder.prototype.toString = function () {
  return this.$to_s()
}

Builder.prototype.getSourceMap = function () {
  return this.$source_map()
}

ERB.$$class.prototype.compile = function (source, fileName) {
  return this.$compile(source, fileName)
}

module.exports.Builder = Builder
module.exports.ERB = ERB
