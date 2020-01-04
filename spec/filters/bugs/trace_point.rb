# NOTE: run bin/format-filters after changing this file
opal_filter "TracePoint" do
  fails "TracePoint#inspect returns a String showing the event, path and line for a :class event"
  fails "TracePoint#inspect returns a String showing the event, path and line"
  fails "TracePoint#inspect returns a string containing a human-readable TracePoint status"
  fails "TracePoint#self return the trace object from event"
end
