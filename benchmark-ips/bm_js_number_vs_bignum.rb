Benchmark.ips do |x|
  x.report("number") do
    %x{
      for (var i = 0; i <= 1000000; i++) {
      }
    }
  end
  x.report("float") do
    %x{
      for (var i = 0.0; i <= 1000000.0; i += 1.0) {
      }
    }
  end
  x.report("bignum") do
    %x{
      for (var i = 0n; i <= 1000000n; i += 1n) {
      }
    }
  end

  x.compare!
end
