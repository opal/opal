class Dir
  @__glob__ = node_require :glob
  `var __glob__ = #{@__glob__}`

  class << self
    def [] glob
      `__glob__.sync(#{glob})`
    end

    def pwd
      `process.cwd()`
    end
    alias getwd pwd
  end
end
