# stub
class ::IO
  def nonblock(boolean = true)
    original_mode = @nonblock
    noblock = boolean
    yield self
  ensure
    nonblock = original_mode
  end

  def nonblock=(boolean)
    @nonblock = !!boolean
  end

  def nonblock?
    @nonblock
  end

  def read_nonblock(length, out_string = nil, options = nil)
    # Reads at most length bytes from ios using the read(2) system call
    # after O_NONBLOCK is set for the underlying file descriptor.
    # If the optional outbuf argument is present, it must reference a String,
    # which will receive the data. The outbuf will contain only the received
    # data after the method call even if it is not empty at the beginning.
    nonblock { read(length, out_string) }
  end

  def write_nonblock(string)
    # Writes the given string to ios using the write(2) system call after O_NONBLOCK is set for the underlying file descriptor.
    nonblock { write(string) }
  end
end
