class Process
  @__clocks__ = []
  def self.__register_clock__(name, func)
    const_set name, @__clocks__.size
    @__clocks__ << func
  end

  __register_clock__ :CLOCK_REALTIME, `function() { return Date.now() }`

  monotonic = false

  %x{
    if (Opal.global.performance) {
      monotonic = function() {
        return performance.now()
      };
    }
    else if (Opal.global.process && process.hrtime) {
      // let now be the base to get smaller numbers
      var hrtime_base = process.hrtime();

      monotonic = function() {
        var hrtime = process.hrtime(hrtime_base);
        var us = (hrtime[1] / 1000) | 0; // cut below microsecs;
        return ((hrtime[0] * 1000) + (us / 1000));
      };
    }
  }

  __register_clock__(:CLOCK_MONOTONIC, monotonic) if monotonic

  def self.pid
    0
  end

  def self.times
    t = Time.now.to_f
    Benchmark::Tms.new(t, t, t, t, t)
  end

  def self.clock_gettime(clock_id, unit = :float_second)
    clock = @__clocks__[clock_id] or raise Errno::EINVAL, "clock_gettime(#{clock_id}) #{@__clocks__[clock_id]}"
    %x{
      var ms = clock();
      switch (unit) {
        case 'float_second':      return  (ms / 1000);         // number of seconds as a float (default)
        case 'float_millisecond': return  (ms / 1);            // number of milliseconds as a float
        case 'float_microsecond': return  (ms * 1000);         // number of microseconds as a float
        case 'second':            return ((ms / 1000)    | 0); // number of seconds as an integer
        case 'millisecond':       return ((ms / 1)       | 0); // number of milliseconds as an integer
        case 'microsecond':       return ((ms * 1000)    | 0); // number of microseconds as an integer
        case 'nanosecond':        return ((ms * 1000000) | 0); // number of nanoseconds as an integer
        default: #{raise ArgumentError, "unexpected unit: #{unit}"}
      }
    }
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
