%x{
  // Minify common function calls
  var $call      = Function.prototype.call;
  var $bind      = Function.prototype.bind;
  var $has_own   = Object.hasOwn || $call.bind(Object.prototype.hasOwnProperty);
  var $set_proto = Object.setPrototypeOf;
  var $slice     = $call.bind(Array.prototype.slice);
  var $splice    = $call.bind(Array.prototype.splice);

  var cnt = 0;
  var fun = function(a,b,c) {
    cnt += a + b + c;
  }
}

Benchmark.ips do |x|
  ary = [1,2,3]
  obj = `{0: 1, 1: 2, 2: 3, length: 3}`

  x.report('Array.from(array)') do
    `fun.apply(null, Array.from(ary))`
  end

  x.report('Array.from(obj)') do
    `fun.apply(null, Array.from(obj))`
  end

  x.report('$slice(array)') do
    `fun.apply(null, $slice(ary))`
  end

  x.report('$slice(obj)') do
    `fun.apply(null, $slice(obj))`
  end

  x.report('array') do
    `fun.apply(null, ary)`
  end

  x.report('obj') do
    `fun.apply(null, obj)`
  end

  x.report('$slice?(array)') do
    `fun.apply(null, ary.$$is_array ? ary : $slice(ary))`
  end

  x.report('$slice?(obj)') do
    `fun.apply(null, obj.$$is_array ? obj : $slice(obj))`
  end

  x.compare!
end
