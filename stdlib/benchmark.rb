module Benchmark

  def measure(&block)
    start = Time.now
    yield
    Time.now - start
  end

  module_function :measure
end
