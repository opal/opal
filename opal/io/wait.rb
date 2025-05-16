class ::IO
  def nread
    # Returns number of bytes that can be read without blocking. Returns zero if no information available.
    0
  end

  def ready?
    # Returns a truthy value if input available without blocking, or a falsy value.
    false
  end

  def wait(events = nil, timeout = nil, mode = :read)
    # Waits until the IO becomes ready for the specified events and returns
    # the subset of events that become ready, or a falsy value when times out.
    raise NotImplementedError
  end

  def wait_priority(timeout = nil)
    # Waits until IO is priority and returns a truthy value or a falsy value when times out.
    # Priority data is sent and received using the Socket::MSG_OOB flag and is typically limited to streams.
    raise NotImplementedError
  end

  def wait_readable(timeout = nil)
    # Waits until IO is readable and returns a truthy value, or a falsy value when times out.
    # Returns a truthy value immediately when buffered data is available.
    raise NotImplementedError
  end

  def wait_writable(timeout = nil)
    # Waits until IO is writable and returns a truthy value or a falsy value when times out.
    raise NotImplementedError
  end
end
