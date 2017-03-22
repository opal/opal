%x{
  function executeIOAction(action) {
    try {
      return action();
    } catch (error) {
      if (error.code === 'EACCES' ||
          error.code === 'EISDIR' ||
          error.code === 'EMFILE' ||
          error.code === 'ENOENT' ||
          error.code === 'EPERM') {
        throw Opal.IOError.$new(error.message)
      }
      throw error;
    }
  }
}

class IO

  @__fs__ = node_require :fs
  `var __fs__ = #{@__fs__}`

  attr_reader :eof
  attr_reader :lineno

  def initialize
    @eof = false
    @lineno = 0
  end

  def read
    if @eof
      ''
    else
      res = `executeIOAction(function(){return __fs__.readFileSync(#{@path}).toString()})`
      @eof = true
      @lineno = res.size
      res
    end
  end

  def each_line(separator = $/, &block)
    if @eof
      return block_given? ? self : [].to_enum
    end

    if block_given?
      lines = File.read(@path)
      %x{
        self.eof = false;
        self.lineno = 0;
        var chomped  = #{lines.chomp},
            trailing = lines.length != chomped.length,
            splitted = chomped.split(separator);
        for (var i = 0, length = splitted.length; i < length; i++) {
          self.lineno += 1;
          if (i < length - 1 || trailing) {
            #{yield `splitted[i] + separator`};
          }
          else {
            #{yield `splitted[i]`};
          }
        }
        self.eof = true;
      }
      self
    else
      read.each_line
    end
  end

  def self.binread(path)
    `return executeIOAction(function(){return __fs__.readFileSync(#{path}).toString('binary')})`
  end
end

STDOUT.write_proc = -> (string) {`process.stdout.write(string)`}
STDERR.write_proc = -> (string) {`process.stderr.write(string)`}

STDOUT.tty = true
STDERR.tty = true
