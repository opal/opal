# backtick_javascript: true
# helpers: platform, coerce_to_or_raise

# Even though we check for platform.ioctl, we don't have implementations for methods
# depending on it yet due to platforms missing support for ioctl.

class ::IO
  class << self
    def console(*args)
      # Returns an File instance opened console.
      # If sym is given, it will be sent to the opened console with args and the result will be returned instead of the console IO itself.
      con = `$platform.windows` ? 'con$' : '/dev/tty'
      if !args.empty?
        sym = args.shift
        File.open(con, 'r+') { |io| io.send(sym, *args) }
      else
        File.open(con, 'r+')
      end
    end
  end

  cursor_move = ->(y, x) do
    y = `$coerce_to_or_raise(#{y}, Opal.Integer, "to_int")`
    x = `$coerce_to_or_raise(#{x}, Opal.Integer, "to_int")`
    printf("\x1b\x5b%d%c", y < 0 ? -y : y, y < 0 ? 'A' : 'B')
    printf("\x1b\x5b%d%c", x < 0 ? -x : x, x < 0 ? 'D' : 'C')
  end

  def beep
    # Beeps on the output console.
    write("\a")
  end

  if `$platform.windows`
    def check_winsize_changed
      # Yields while console input events are queued.
      # This method is Windows only.
      self
    end
  else
    alias check_winsize_changed __not_implemented__
  end

  def clear_screen
    # Clears the entire screen and moves the cursor top-left corner.
    printf("\x1b\x5b%dJ", 2) # clear
    goto(0, 0)
    self
  end

  if `$platform.ioctl`
    def cooked
      # Yields self within cooked mode.
      yield self
    end

    def cooked!
      # Enables cooked mode.
      self
    end

    def console_mode
      # Returns a data represents the current console mode.
      nil
    end

    def console_mode=(m)
      # Sets the console mode to mode.
      m
    end
  else
    alias cooked __not_implemented__
    alias cooked! __not_implemented__
    alias console_mode __not_implemented__
    alias console_mode= __not_implemented__
  end

  if `$platform.ioctl`
    def cursor
      # Returns the current cursor position as a two-element array of integers (row, column)
      raw do
        write "\033[6n"
        # an then a few getbytes with some mangling
      end
    end
  else
    alias cursor __not_implemented__
  end

  def cursor=(line, column)
    # Set the cursor position at line and column.
    line = `$coerce_to_or_raise(#{line}, Opal.Integer, "to_int")`
    column = `$coerce_to_or_raise(#{column}, Opal.Integer, "to_int")`
    printf("\x1b\x5b%d;%dH", line, column)
    self
  end

  def cursor_down(n)
    # Moves the cursor down n lines.
    cursor_move.call(n, 0)
  end

  def cursor_left(n)
    # Moves the cursor left n columns.
    cursor_move.call(0, -n)
  end

  def cursor_right(n)
    # Moves the cursor right n columns.
    cursor_move.call(0, n)
  end

  def cursor_up(n)
    # Moves the cursor up n lines.
    cursor_move.call(-n, 0)
  end

  if `$platform.ioctl`
    def echo=(flag)
      # Enables/disables echo back.
      # On some platforms, all combinations of this flags and raw/cooked mode may not be valid.
      flag
    end

    def echo?
      # Returns true if echo back is enabled.
      false
    end
  else
    alias echo= __not_implemented__
    alias echo? __not_implemented__
  end

  def erase_line(mode)
    # Erases the line at the cursor corresponding to mode. mode may be either:
    # 0: after cursor
    # 1: before cursor
    # 2: entire line
    mode = `$coerce_to_or_raise(#{mode}, Opal.Integer, "to_int")`
    printf("\x1b\x5b%dK", mode)
  end

  def erase_screen(mode)
    # Erases the screen at the cursor corresponding to mode. mode may be either:
    # 0: after cursor
    # 1: before and cursor
    # 2: entire screen
    mode = `$coerce_to_or_raise(#{mode}, Opal.Integer, "to_int")`
    printf("\x1b\x5b%dJ", mode)
  end

  if `$platform.ioctl`
    def getch(min: nil, time: nil, intr: nil)
      # Reads and returns a character in raw mode.
      raw { getc }
    end

    def getpass(prompt = nil)
      # Reads and returns a line without echo back. Prints prompt unless it is nil.
      noecho { gets }
    end
  else
    alias getch __not_implemented__
    alias getpass __not_implemented__
  end

  # Set the cursor position at line and column.
  alias goto cursor=

  def goto_column(col)
    # Set the cursor position at column in the same line of the current position.
    col = `$coerce_to_or_raise(#{col}, Opal.Integer, "to_int")`
    printf("\x1b\x5b%dG", col + 1)
    self
  end

  def iflush
    # Flushes input buffer in kernel.
    self
  end

  def ioflush
    # Flushes input and output buffers in kernel.
    self
  end

  if `$platform.ioctl`
    def noecho
      # Yields self with disabling echo back.
      yield self
    end
  else
    alias noecho __not_implemented__
  end

  def oflush
    # Flushes output buffer in kernel.
    self
  end

  if `$platform.windows`
    def pressed?(p1)
      # Returns true if key is pressed. key may be a virtual key code or its name
      # (String or Symbol) with out “VK_” prefix.
      false
    end
  else
    alias pressed? __not_implemented__
  end

  if `$platform.ioctl`
    def raw(min: nil, time: nil, intr: nil)
      # Yields self within raw mode, and returns the result of the block.
      yield self
    end

    def raw!(min: nil, time: nil, intr: nil)
      # Enables raw mode, and returns io.
      self
    end
  else
    alias raw __not_implemented__
    alias raw! __not_implemented__
  end

  def scroll_backward(n)
    # Scrolls the entire scrolls backward n lines.
    printf("\x1b\x5b%d%c", -n, 'T')
  end

  def scroll_forward(n)
    # Scrolls the entire scrolls forward n lines.
    printf("\x1b\x5b%d%c", n, 'S')
  end

  if `$platform.ttyname`
    def ttyname
      # Returns name of associated terminal (tty) if io is not a tty. Returns nil otherwise.
      `$platform.ttyname(self.$fileno())`
    end
  end

  if `$platform.ioctl`
    def winsize
      # Returns console size.
      # something like: ioctl 0x00005413, buf
      [25, 80]
    end

    def winsize=(arr)
      # Tries to set console size. The effect depends on the platform and the running environment.
      # something like: ioctl 0x00005412, buf
      arr[0] = `$coerce_to_or_raise(arr[0], Opal.Integer, "to_int")`
      arr[1] = `$coerce_to_or_raise(arr[1], Opal.Integer, "to_int")`
      winsize
    end
  else
    alias winsize __not_implemented__
    alias winsize= __not_implemented__
  end
end
