# frozen_string_literal: true

require 'opal/regexp_anchors'
require 'opal/hike'

module Opal
  class PathReader
    RELATIVE_PATH_REGEXP = /#{Opal::REGEXP_START}\.?\.#{Regexp.quote File::SEPARATOR}/.freeze
    CURRENT_DIR_REGEXP = /#{Opal::REGEXP_START}\.#{Regexp.quote File::SEPARATOR}/.freeze
    DEFAULT_EXTENSIONS = ['.js', '.js.rb', '.rb', '.opalerb'].freeze

    # @param cwd [String, nil] the directory a leading './' is resolved
    #   against, as MRI does. When nil, './foo' is looked up in the load path
    #   instead. See {#expand}.
    def initialize(paths = Opal.paths, extensions = DEFAULT_EXTENSIONS, cwd: nil)
      @file_finder = Hike::Trail.new
      @file_finder.append_paths(*paths)
      @file_finder.append_extensions(*extensions)
      @cwd = cwd
    end

    attr_accessor :cwd

    def read(path)
      full_path = expand(path)
      return nil if full_path.nil?
      File.open(full_path, 'rb:UTF-8', &:read) if File.exist?(full_path)
    end

    # Resolves a require string to a file on disk.
    #
    # A leading './' gets special treatment. Whichever way it resolves, the
    # module is emitted under the same key: the compiler derives it from the
    # require string via `Compiler.module_name`, which cleanpaths './foo' to
    # 'foo', and the runtime's `Opal.normalize` strips the './' too. So the
    # choice below only decides *which file is read*, never how it is named.
    #
    # With a {#cwd} set, './foo' resolves against it, as MRI resolves against
    # the process CWD. Without one, the './' is stripped and looked up in the
    # load path, so `require './foo'` finds the same asset as `require 'foo'`.
    # Only entry points that have a meaningful working directory set a cwd —
    # the CLI does; a build task or Sprockets does not.
    #
    # Paths that are absolute, or start with '../', are returned verbatim: the
    # load path cannot express them.
    def expand(path)
      if Pathname.new(path).absolute? || path =~ RELATIVE_PATH_REGEXP
        stripped = strip_current_dir(path)
        return path unless stripped
        expand_current_dir(stripped) || path
      else
        find_path(path)
      end
    end

    def paths
      file_finder.paths
    end

    def extensions
      file_finder.extensions
    end

    def append_paths(*paths)
      file_finder.append_paths(*paths)
    end

    private

    # Returns the path without its leading './', or nil when there's none.
    def strip_current_dir(path)
      stripped = path.sub(CURRENT_DIR_REGEXP, '')
      stripped unless stripped == path
    end

    # Resolves a './' require, with the leading './' already stripped. Tries
    # the cwd first when there is one, then the load path.
    def expand_current_dir(path)
      find_in_cwd(path) || find_path(path)
    end

    # Looks the path up inside the cwd, trying the known extensions the way the
    # load path lookup does, so that `require './foo'` finds 'foo.rb'.
    def find_in_cwd(path)
      return nil unless cwd

      candidate = File.expand_path(path, cwd)

      ([''] + extensions).each do |extension|
        with_extension = candidate + extension
        return with_extension if File.file?(with_extension)
      end

      nil
    end

    def find_path(path)
      pathname = Pathname(path)
      return path if pathname.absolute? && pathname.exist?
      file_finder.find(path)
    end

    attr_reader :file_finder
  end
end
