class Dir
  `__glob__ = OpalNode.node_require('glob')`

  def self.[] glob
    `__glob__.sync(#{glob})`
  end

  def pwd
    `process.cwd()`
  end
  alias getwd pwd
end
