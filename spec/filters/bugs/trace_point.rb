# NOTE: run bin/format-filters after changing this file
opal_filter "TracePoint" do
  fails "TracePoint#inspect returns a String showing the event and thread for :thread_begin event" # RuntimeError: Only the :class event is supported
  fails "TracePoint#inspect returns a String showing the event and thread for :thread_end event" # RuntimeError: Only the :class event is supported
  fails "TracePoint#inspect returns a String showing the event, method, path and line for a :c_call event" # RuntimeError: Only the :class event is supported
  fails "TracePoint#inspect returns a String showing the event, method, path and line for a :call event" # RuntimeError: Only the :class event is supported
  fails "TracePoint#inspect returns a String showing the event, method, path and line for a :return event" # RuntimeError: Only the :class event is supported
  fails "TracePoint#inspect returns a String showing the event, path and line for a :class event"
  fails "TracePoint#inspect returns a String showing the event, path and line"
  fails "TracePoint#inspect returns a string containing a human-readable TracePoint status"
  fails "TracePoint#self return the trace object from event"
end
