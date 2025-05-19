# NOTE: run bin/format-filters after changing this file
opal_filter "Exception" do
  fails "Exception#backtrace contains lines of the same format for each prior position in the stack" # Expected "http://localhost:9445/index.js:168275:15:in `'" =~ /^.+:\d+:in `[^`]+'$/ to be truthy but was nil
  fails "Interrupt.new returns an instance of interrupt with no message given" # NoMethodError: undefined method `[]' for nil
  fails "Interrupt.new takes an optional message argument" # NoMethodError: undefined method `[]' for nil
  fails "SignalException can be rescued" # NotImplementedError: NotImplementedError
  fails "SignalException#signm returns the signal name" # Expected SignalException but got: NotImplementedError (NotImplementedError)
  fails "SignalException#signo returns the signal number" # Expected SignalException but got: NotImplementedError (NotImplementedError)
  fails "SignalException.new raises an exception with an invalid signal name" # Expected ArgumentError but got: NoMethodError (undefined method `[]' for nil)
  fails "SignalException.new raises an exception with an invalid signal number" # Expected ArgumentError but got: NoMethodError (undefined method `key' for nil)
  fails "SignalException.new takes a signal name with SIG prefix as the first argument" # NoMethodError: undefined method `[]' for nil
  fails "SignalException.new takes a signal name without SIG prefix as the first argument" # NoMethodError: undefined method `[]' for nil
  fails "SignalException.new takes a signal number as the first argument" # NoMethodError: undefined method `[]' for nil
  fails "SignalException.new takes a signal symbol with SIG prefix as the first argument" # NoMethodError: undefined method `[]' for nil
  fails "SignalException.new takes a signal symbol without SIG prefix as the first argument" # NoMethodError: undefined method `[]' for nil
  fails "SignalException.new takes an optional message argument with a signal number" # NoMethodError: undefined method `[]' for nil
  fails "SystemExit sets the exit status and exits silently when raised when subclassed" # NotImplementedError: NotImplementedError
  fails "SystemExit sets the exit status and exits silently when raised" # NotImplementedError: NotImplementedError
  fails "The rescue keyword without rescue expression will not rescue exceptions except StandardError" # ArgumentError: unknown signal
end
