# https://github.com/opal/opal/issues/1659#issuecomment-298222232

Benchmark.ips do |x|
  a = []

  50.times do |i|
    a << %(#{i}\n)
  end

  x.report('map block') do
    a.map {|it| it.chomp }
  end

  x.report('map symbol') do
    a.map(&:chomp)
  end

  x.compare!
end
