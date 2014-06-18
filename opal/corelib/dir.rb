class Dir
  class << self
    def chdir(dir)
      prev_cwd = `$opal.current_dir`
      `$opal.current_dir = #{dir}`
      `console.log($opal.current_dir, #{prev_cwd}, #{dir});`
      yield
    ensure
      `$opal.current_dir = #{prev_cwd}`
    end

    def pwd
      `$opal.current_dir` || '.'
    end
    alias getwd pwd
  end
end
