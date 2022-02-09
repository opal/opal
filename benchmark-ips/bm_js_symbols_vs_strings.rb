Benchmark.ips do |x|
  %x{
    const c_foo = 'foo'
    const v_foo = 'foo'
    const cfoo = Symbol('foo')
    var vfoo = Symbol('foo')
    const cgfoo = Symbol.for('foo')
    var vgfoo = Symbol.for('foo')

    var o = {}
    o[cfoo] = 1
    o[cgfoo] = 1
    o[c_foo] = 1
    o[vfoo] = 1

    let a1 = 0, a2 = 0, a3 = 0, a4 = 0, a5 = 0, a6 = 0, a7 = 0, a8 = 0
  }

  x.report('const string ref') do
    `a1 += o[c_foo]`
  end

  x.report('var string ref') do
    `a2 += o[v_foo]`
  end

  x.report('live global symbol') do
    `a3 += o[Symbol.for('foo')]`
  end

  x.report('const global symbol') do
    `a4 += o[cgfoo]`
  end

  x.report('var global symbol') do
    `a5 += o[vgfoo]`
  end

  x.report('const symbol') do
    `a6 += o[cfoo]`
  end

  x.report('var symbol') do
    `a6 += o[vfoo]`
  end

  x.report('ident') do
    `a7 += o.foo`
  end

  x.report('live string') do
    `a8 += o['foo']`
  end

  x.time = 10

  x.compare!
end
