class ::IO
  class << self
    def console(sym, *args)
      # Returns an File instance opened console.
      # If sym is given, it will be sent to the opened console with args and the result will be returned instead of the console IO itself.
      raise NotImplementedError
    end
  end

  def beep
    write("\a")
  end

  def check_winsize_changed
    self
  end

  def clear_screen
    self
  end

  def console_mode
    # Returns a data represents the current console mode.
    @console_mode
  end

  def console_mode=(mode)
    # Sets the console mode to mode.
    @console_mode = mode
  end

  def cooked
    # Yields self within cooked mode.
    cooked!
    yield self
  ensure

  end

  def cooked!
    # Enables cooked mode.
  end

  def cursor
    # Returns the current cursor position as a two-element array of integers (row, column)
    [0, 0]
  end

  def cursor=(p1)
  end

  def cursor_down(p1)
  end

  def cursor_left(p1)
  end

  def cursor_right(p1)
  end

  def cursor_up(p1)
  end

  def echo=(flag)
    # Enables/disables echo back.
    # On some platforms, all combinations of this flags and raw/cooked mode may not be valid.
  end

  def echo?
    # Returns true if echo back is enabled.
    false
  end

  def getch(min: nil, time: nil, intr: nil)
    # Reads and returns a character in raw mode.
  end

  def getpass(prompt = nil)
    # Reads and returns a line without echo back. Prints prompt unless it is nil.
  end

  def iflush
    # Flushes input buffer in kernel.
  end

  def ioflush
    # Flushes input and output buffers in kernel.
  end

  def noecho
    # Yields self with disabling echo back.
    yield self
  end

  def oflush
    # Flushes output buffer in kernel.
    self
  end

  def pressed?(p1)
  end

  def raw(min: nil, time: nil, intr: nil)
    # Yields self within raw mode, and returns the result of the block.
  end

  def raw!(min: nil, time: nil, intr: nil)
    # Enables raw mode, and returns io.
    self
  end

  def winsize
    # Returns console size.
    [25, 80]
  end

  def winsize=(arr)
    # Tries to set console size. The effect depends on the platform and the running environment.
  end
end
