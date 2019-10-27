o = nil
Benchmark.ips do |x|
  x.report('shovel') do
    o = Object.new
    class << o
      attr_accessor :foo
    end
  end

  x.report('singleton_class') do
    o2 = Object.new
    o2.singleton_class.attr_accessor :foo
  end

  x.compare!
end
