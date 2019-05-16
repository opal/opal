opal_unsupported_filter "language" do
  fails "Magic comment can be after the shebang"
  fails "Magic comment can take Emacs style"
  fails "Magic comment can take vim style"
  fails "Magic comment determines __ENCODING__"
  fails "Magic comment is case-insensitive"
  fails "Magic comment must be at the first line"
  fails "Magic comment must be the first token of the line"
  fails "The defined? keyword for pseudo-variables returns 'expression' for __ENCODING__"
  fails "The defined? keyword when called with a method name having a module as receiver returns nil if the method is private"
  fails "The defined? keyword when called with a method name having a module as receiver returns nil if the method is protected"
  fails "The private keyword changes the visibility of the existing method in the subclass"
  fails "The private keyword changes visibility of previously called method"
  fails "The private keyword changes visibility of previously called methods with same send/call site" # Expected NoMethodError but no exception was raised (2 was returned)
  fails "The private keyword is overridden when a new class is opened"
  fails "The private keyword marks following methods as being private"
  fails "Ruby String literals with a magic frozen comment produce different objects for literals with the same content in different files if the other file doesn't have the comment"
  fails "Ruby String literals with a magic frozen comment produce different objects for literals with the same content in different files if they have different encodings"
  fails "Ruby String literals with a magic frozen comment produce the same object each time"
  fails "Ruby String literals with a magic frozen comment produce the same object for literals with the same content"
  fails "Ruby String literals with a magic frozen comment produce the same object for literals with the same content in different files"
  fails "rescuing Interrupt raises an Interrupt when sent a signal SIGINT" # NoMethodError: undefined method `kill' for Process
  fails "rescuing SignalException raises a SignalException when sent a signal" # NoMethodError: undefined method `kill' for Process
end
