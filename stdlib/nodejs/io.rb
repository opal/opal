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
  @__fs__ = `require('fs')`
  `var __fs__ = #{@__fs__}`

  attr_reader :eof
  attr_reader :lineno

  def initialize
    @eof = false
    @lineno = 0
  end

  def self.write(path, data)
    File.write(path, data)
  end

  def self.read(path)
    File.read(path)
  end

  def self.binread(path)
    `return executeIOAction(function(){return __fs__.readFileSync(#{path}).toString('binary')})`
  end
end

STDOUT.write_proc = ->(string) { `process.stdout.write(string)` }
STDERR.write_proc = ->(string) { `process.stderr.write(string)` }

STDOUT.tty = true
STDERR.tty = true
