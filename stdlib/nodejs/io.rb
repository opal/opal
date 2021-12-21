require 'nodejs/file'

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

`var __fs__ = require('fs')`

class IO
  @__fs__ = `__fs__`

  attr_reader :lineno

  alias initialize_before_node_io initialize

  def initialize(fd, flags = 'r')
    @lineno = 0
    initialize_before_node_io(fd, flags)
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
