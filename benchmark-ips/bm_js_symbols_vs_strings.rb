Benchmark.ips do |x|
  %x{
    var o = {}
    o[Symbol.for('foo')] = 123
    o.foo = 123
    var foo = Symbol('foo')
    var gfoo = Symbol.for('foo')
    o[foo] = 123
    var a = 0, b = 0, c = 0
  }

  x.report('live global symbol') do
    `a += o[Symbol.for('foo')]`
  end

  x.report('stored global symbol') do
    `a += o[gfoo]`
  end

  x.report('stored symbol') do
    `a += o[foo]`
  end

  x.report('ident') do
    `b += o.foo`
  end

  x.report('string') do
    `c += o['foo']`
  end

  x.compare!
end
