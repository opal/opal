class ::Dir
  class << self
    def chdir(dir)
      prev_cwd = `Opal.current_dir`
      `Opal.current_dir = #{dir}`
      yield
    ensure
      `Opal.current_dir = #{prev_cwd}`
    end

    def pwd
      `Opal.current_dir || '.'`
    end

    def home
      ::ENV['HOME'] || '.'
    end

    alias getwd pwd
  end
end
