class Process
  CLOCK_REALTIME  = 0
  CLOCK_MONOTONIC = 1

  def self.pid
    0
  end

  def self.times
    t = Time.now.to_f
    Benchmark::Tms.new(t, t, t, t, t)
  end

  def self.clock_gettime(clock_id, unit = nil)
    Time.now.to_f
  end
end

class Signal
  def self.trap(*)
  end
end

class GC
  def self.start
  end
end
