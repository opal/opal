class TracePoint
  # partial implementation of TracePoint
  # for the moment only supports the :class event
  def self.trace(event, &block)
    new(event, &block).enable
  end

  attr_reader :event

  def initialize(event, &block)
    raise 'Only the :class event is supported' unless event == :class
    @event = event
    @block = block
    @trace_object = nil
    @trace_evt = "trace_#{@event}"
    @tracers_for_evt = "tracers_for_#{@event}"
  end

  def enable(*args, &enable_block)
    previous_state = enabled?
    %x{
      Opal[#{@tracers_for_evt}].push(self);
      Opal[#{@trace_evt}] = true;
    }
    if block_given?
      yield
      disable
    end
    previous_state
  end

  def enabled?
    %x{
      if (Opal[#{@trace_evt}] && Opal[#{@tracers_for_evt}].includes(self)) { return true; }
      else { return false; }
    }
  end

  def disable
    %x{
      var idx = Opal[#{@tracers_for_evt}].indexOf(self)
      if (idx > -1) {
        Opal[#{@tracers_for_evt}].splice(idx, 1);
        if (Opal[#{@tracers_for_evt}].length == 0) {
          Opal[#{@trace_evt}] = false;
        }
        return true;
      } else {
        return false;
      }
    }
  end

  def self
    @trace_object
  end
end
