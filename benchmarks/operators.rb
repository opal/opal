require "benchmark"

time = Benchmark.measure do
  a = 0
  100000.times do
    a = a + 1
  end
  puts a
end

puts time
