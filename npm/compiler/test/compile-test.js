const {describe, it} = require('node:test')
const assert = require('node:assert')
const Opal = require('@opal/runtime').Opal
const Builder = require('../src/index').Builder
const ERB = require('../src/index').ERB

describe('Opal Node Compiler', function () {
  describe('When loaded', function () {
    it('should export Opal object', function () {
      assert.notStrictEqual(Opal, null)
    })

    it('should export Builder object', function () {
      assert.notStrictEqual(Builder, null)
    })
  })

  describe('Builder', function () {
    it('should compile a simple hello world', function () {
      const builder = Builder.create()
      const result = builder.build('spec/fixtures/hello.rb')
      assert.match(result.toString(), /self\.\$puts\("Hello world"\)/)
    })

    it('should compile a simple inline hello world', function () {
      const builder = Builder.create()
      const result = builder.buildString('puts "Hello world"')
      assert.match(result.toString(), /self\.\$puts\("Hello world"\)/)
    })

    it('should compile a simple hello world library', function () {
      const builder = Builder.create()
      builder.appendPaths('spec/fixtures/hello-ruby/lib')
      builder.appendPaths('src/stdlib')
      const result = builder.build('hello')
      assert.match(result.toString(), /self\.\$puts\("Hello world"\)/)
    })

    it('should use front slash as module name', function () {
      const builder = Builder.create()
      builder.appendPaths('spec/fixtures/hello-ruby/lib')
      builder.appendPaths('src/stdlib')
      const result = builder.build('french/bonjour', {requirable: true})
      assert.match(result.toString(), /Opal\.modules\["french\/bonjour"]/)
    })

    it('should compile a module that require a built-in Ruby module (logger)', function () {
      const builder = Builder.create()
      builder.appendPaths('src/stdlib')
      const result = builder.build('spec/fixtures/logging.rb')
      assert.match(result.toString(), /Opal\.modules\["logger"\]/)
    })

    it('should retrieve source maps', function () {
      const builder = Builder.create()
      builder.appendPaths('src/stdlib')
      builder.build('spec/fixtures/logging.rb')
      const sourceMap = builder.getSourceMap().source_maps[0]
      assert.strictEqual(sourceMap.file, 'logger.rb')
      assert.match(sourceMap.source, /class Logger/)
    })
  })

  describe('ERB compiler', function () {
    it('should compile an ERB template', function () {
      const result = ERB.compile('The value of x is: <%= x %>')
      assert.match(result.toString(), /output_buffer\.\$append\("The value of x is: "\)/)
    })
  })
})
