class IO
  SEEK_SET = 0
  SEEK_CUR = 1
  SEEK_END = 2

  module Writable
    def <<(string)
      write(string)

      self
    end

    def print(*args)
      write args.map { |arg| String(arg) }.join($,)
    end

    def puts(*args)
      write args.map { |arg| String(arg) }.join($/)
    end
  end

  module Readable
    def readbyte
      getbyte
    end

    def readchar
      getc
    end

    def readline(sep = $/)
      raise NotImplementedError
    end

    def readpartial(integer, outbuf = nil)
      raise NotImplementedError
    end
  end
end
