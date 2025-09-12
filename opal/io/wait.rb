class ::IO
  def nread
    # Returns number of bytes that can be read without blocking. Returns zero if no information available.
    0
  end

  def ready?
    # Returns a truthy value if input available without blocking, or a falsy value.
    false
  end

  # Waits until the IO becomes ready for the specified events and returns
  # the subset of events that become ready, or a falsy value when times out.
  alias wait __not_implemented__

  # Waits until IO is priority and returns a truthy value or a falsy value when times out.
  # Priority data is sent and received using the Socket::MSG_OOB flag and is typically limited to streams.
  alias wait_priority __not_implemented__

  # Waits until IO is readable and returns a truthy value, or a falsy value when times out.
  # Returns a truthy value immediately when buffered data is available.
  alias wait_readable __not_implemented__

  # Waits until IO is writable and returns a truthy value or a falsy value when times out.
  alias wait_writable __not_implemented__
end
