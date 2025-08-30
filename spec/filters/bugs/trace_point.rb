# NOTE: run bin/format-filters after changing this file
opal_filter "TracePoint" do
  fails "TracePoint#inspect returns a String showing the event and thread for :thread_begin event" # RuntimeError: Only the :class event is supported
  fails "TracePoint#inspect returns a String showing the event and thread for :thread_end event" # RuntimeError: Only the :class event is supported
  fails "TracePoint#inspect returns a String showing the event, method, path and line for a :c_call event" # RuntimeError: Only the :class event is supported
  fails "TracePoint#inspect returns a String showing the event, method, path and line for a :call event" # RuntimeError: Only the :class event is supported
  fails "TracePoint#inspect returns a String showing the event, method, path and line for a :return event" # RuntimeError: Only the :class event is supported
  fails "TracePoint#inspect returns a String showing the event, path and line for a :class event" # Expected "#<TracePoint:0x89c86 @event=\"class\" @block=#<Proc:0x89c88> @trace_object=TracePointSpec::C @trace_evt=\"trace_class\" @tracers_for_evt=\"tracers_for_class\">" == "#<TracePoint:class ruby/core/tracepoint/inspect_spec.rb:87>" to be truthy but was false
  fails "TracePoint#inspect returns a String showing the event, path and line" # RuntimeError: Only the :class event is supported
  fails "TracePoint#inspect returns a string containing a human-readable TracePoint status" # RuntimeError: Only the :class event is supported
  fails "TracePoint#inspect shows only whether it's enabled when outside the TracePoint handler" # RuntimeError: Only the :class event is supported
  fails "TracePoint#self return the trace object from event" # RuntimeError: Only the :class event is supported
end
