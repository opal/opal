module A
  module B
    module C
      Benchmark.ips do |x|
        x.report("Kernel") { Kernel }
        x.report("::Kernel"){ ::Kernel }
        x.compare!
      end
    end
  end
end
