# NOTE: run bin/format-filters after changing this file
opal_filter "Exception" do
  fails "Interrupt.new returns an instance of interrupt with no message given" # ArgumentError: unknown signal
  fails "Interrupt.new takes an optional message argument" # ArgumentError: unknown signal
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
