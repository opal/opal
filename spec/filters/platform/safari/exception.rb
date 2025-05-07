# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Exception" do
  fails "Exception#backtrace contains lines of the same format for each prior position in the stack"
  fails "Exception#backtrace sets each element to a String"
  fails "Exception#backtrace_locations sets each element to a Thread::Backtrace::Location"
  fails "Interrupt.new returns an instance of interrupt with no message given" # ArgumentError: unknown signal
  fails "Interrupt.new takes an optional message argument" # ArgumentError: unknown signal
  fails "Invoking a method when the method is not available should omit the method_missing call from the backtrace for NameError"
  fails "Invoking a method when the method is not available should omit the method_missing call from the backtrace for NoMethodError"
  fails "SignalException#signm returns the signal name" # Expected SignalException but got: ArgumentError (unknown signal)
  fails "SignalException#signo returns the signal number" # Expected SignalException but got: ArgumentError (unknown signal)
  fails "SignalException.new takes a signal name with SIG prefix as the first argument" # ArgumentError: unknown signal
  fails "SignalException.new takes a signal name without SIG prefix as the first argument" # ArgumentError: unknown signal
  fails "SignalException.new takes a signal number as the first argument" # ArgumentError: signal must be Integer, String or Symbol
  fails "SignalException.new takes a signal symbol with SIG prefix as the first argument" # ArgumentError: unknown signal
  fails "SignalException.new takes a signal symbol without SIG prefix as the first argument" # ArgumentError: unknown signal
  fails "SignalException.new takes an optional message argument with a signal number" # ArgumentError: signal must be Integer, String or Symbol
  fails "The rescue keyword without rescue expression will not rescue exceptions except StandardError" # ArgumentError: unknown signal
end
