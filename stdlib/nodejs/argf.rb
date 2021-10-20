ARGF = Object.new

class << ARGF
  include Enumerable

  def inspect
    'ARGF'
  end

  def argv
    ARGV
  end

  def file
    fn = filename
    if fn == '-'
      $stdin
    else
      @file ||= File.open(fn, 'r')
    end
  end

  def filename
    return @filename if @filename
    if argv == ['-']
      '-'
    elsif argv == []
      @last_filename || '-'
    else
      @file = nil
      @filename = @last_filename = argv.shift
    end
  end

  def close
    file.close
    @filename = nil
    self
  end

  def closed?
    file.closed?
  end

  def each(*args, &block)
    return enum_for(:each) unless block_given?

    while (l = gets(*args))
      yield(l)
    end
  end

  def gets(*args)
    s = file.gets(*args)
    if s.nil?
      close
      s = file.gets(*args)
    end
    @lineno += 1 if s
    s
  end

  def read(len = nil)
    buf = ''
    loop do
      r = file.read(len)
      if r
        buf += r
        len -= r.length
      end
      file.close
      break if len && len > 0 && @filename
    end
  end

  def readlines(*args)
    each(*args).to_a
  end

  attr_accessor :lineno

  def rewind
    @lineno = 1
    f = file
    begin
      f.rewind
    rescue
      nil
    end
    0
  end

  def fileno
    return 0 if !@filename && @last_filename
    file.fileno
  end

  def eof?
    file.eof?
  end

  alias to_io file
  alias to_i fileno
  alias skip close
  alias path filename
  alias each_line each
  alias eof eof?
end

ARGF.lineno = 1
