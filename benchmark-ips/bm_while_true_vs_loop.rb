Benchmark.ips do |x|
  x.report('while true') do
    n = 0
    while true
      n += 1
      break if n == 10000
    end
  end

  x.report('loop') do
    n = 0
    loop do
      n += 1
      break if n == 10000
    end
  end

  x.compare!
end
