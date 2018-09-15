class Dir
  @__glob__ = `require('glob')`
  @__fs__ = `require('fs')`
  `var __glob__ = #{@__glob__}`
  `var __fs__ = #{@__fs__}`

  class << self
    def [](glob)
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
        for (var i = 0, ii = entries.length; i < ii; i++) {
          result.push(entries[i]);
        }
        return result;
      }
    end

    def glob(pattern)
      pattern = [pattern] unless pattern.respond_to? :each
      pattern.flat_map do |subpattern|
        subpattern = subpattern.to_path if subpattern.respond_to? :to_path
        subpattern = Opal.coerce_to!(subpattern, String, :to_str)
        `__glob__.sync(subpattern)`
      end
    end

    alias getwd pwd
  end
end
