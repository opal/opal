# backtick_javascript: true

# ::Opal::Raw.npm_dependency 'glob', '7.1.3' # TODO

class Dir
  @__glob__ = Opal::Raw.import('glob')
  @__fs__ = Opal::Raw.import('node:fs')
  @__path__ = Opal::Raw.import('node:path')
  @__os__ = Opal::Raw.import('node:os')
  `var __glob__ = #{@__glob__}`
  `var __fs__ = #{@__fs__}`
  `var __path__ = #{@__path__}`
  `var __os__ = #{@__os__}`

  class << self
    def [](glob)
      `__glob__.sync(#{glob})`
    end

    def pwd
      `process.cwd().split(__path__.sep).join(__path__.posix.sep)`
    end

    def home
      `__os__.homedir()`
    end

    def chdir(path)
      `process.chdir(#{path})`
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
        subpattern = ::Opal.coerce_to!(subpattern, String, :to_str)
        `__glob__.sync(subpattern)`
      end
    end

    alias getwd pwd
  end
end
