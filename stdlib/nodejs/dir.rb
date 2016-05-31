class Dir
  @__glob__ = node_require :glob
  @__fs__ = node_require :fs
  `var __glob__ = #{@__glob__}`
  `var __fs__ = #{@__fs__}`

  class << self
    def [] glob
      `__glob__.sync(#{glob})`
    end

    def pwd
      `process.cwd()`
    end

    def mkdir(path)
      `__fs__.mkdirSync(#{path})`
    end

    def entries(dirname)
      %x{
        var result = [];
        var entries = __fs__.readdirSync(#{dirname});
        for (var i = 0; i < entries.length; i++) {
          result.push(entries[i]);
        }
        return result;
      }
    end

    alias getwd pwd
  end
end
