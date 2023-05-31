module BmBlockVsYield
  def self._block(&block)
    block.call
  end

  def self._yield
    yield
  end
end

Benchmark.ips do |x|
  x.warmup = 10
  x.time = 60

  x.report('block') do
    BmBlockVsYield._block { 1+1 }
  end

  x.report('yield') do
    BmBlockVsYield._yield { 1+1 }
  end

  x.compare!
end
