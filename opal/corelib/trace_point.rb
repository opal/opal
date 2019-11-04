class TracePoint
  # partial implementation of TracePoint
  # for the moment only supports the :class event
  def self.trace(event, &block)
    new(event, &block).enable
  end

  attr_reader :event

  def intialize(event, &block)
    raise RuntimeError, "Only the :class event is supported" unless event == :class
    @trace_evt = "trace_#{@event}"
    @tracers_for_evt = "tracers_for_#{@event}"
    @event = event
    @block = block
  end

  def enable
    `Opal[#@tracers_for_evt].push(self)`
  end

  def enabled?
   `Opal[#@tracers_for_evt].includes(self)`
  end

  def disable
    %x{
      var idx = Opal[#@tracers_for_evt].indexOf(self)
      if (idx > -1) {
        Opal[#@tracers_for_evt].splice(idx, 1);
        return true;
      } else {
        return false;
      }
    }
  end
end
