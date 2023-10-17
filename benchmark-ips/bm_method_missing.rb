class B
  def method_missing(a, b, c, d)
    "#{a} #{b} #{c} #{d}"
  end
end

Benchmark.ips do |x|
  b = B.new
  x.report("method missing") do
    b.a(1,2,3)
  end

  x.compare!
end
