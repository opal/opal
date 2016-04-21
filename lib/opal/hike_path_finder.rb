require 'hike'
require 'pathname'

module Opal
  class HikePathFinder < Hike::Trail
    def initialize(paths = Opal.paths)
      super()
      append_paths(*paths)
      append_extensions '.js', '.js.rb', '.rb', '.opalerb'
      @patterns = {}
    end

    def find path, options={}
      pathname = Pathname(path)
      return path if pathname.absolute? and pathname.exist?
      super
    end

    def find_relative_current_dir path
      # Hike is great, but doesn't seem to do very well when trying to deal with relative paths (.. in particular)
      basename = File.basename(path)
      dirname = Pathname(path).dirname
      pattern = pattern_for basename
      matches = entries(dirname)
      matches = matches.select { |m| m.to_s =~ pattern }
      sort_matches(matches, basename).each do |path|
        pathname = dirname.join(path)

        # Potential `stat` syscall
        stat = stat(pathname)

        # Exclude directories
        if stat && stat.file?
          return pathname.expand_path.to_s
        end
      end
    end

    private

    def sort_matches(matches, basename)
      aliases = []

      matches.sort_by do |match|
        extnames = match.sub(basename.to_s, '').to_s.scan(/\.[^.]+/)
        extnames.inject(0) do |sum, ext|
          if i = extensions.index(ext)
            sum + i + 1
          elsif i = aliases.index(ext)
            sum + i + 11
          else
            sum
          end
        end
      end
    end

    def pattern_for(basename)
      @patterns[basename] ||= build_pattern_for(basename)
    end

    def build_pattern_for(basename)
      basename_re = Regexp.escape(basename.to_s)
      extension_pattern = extensions.map { |e| Regexp.escape(e) }.join("|")
      /^#{basename_re}(?:#{extension_pattern})*$/
    end
  end
end
