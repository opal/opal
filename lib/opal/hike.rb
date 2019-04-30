# frozen_string_literal: true

# Copyright (c) 2011 Sam Stephenson
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'pathname'

module Opal
  # Taken from hike v1.2.3
  module Hike
    # `Index` is an internal cached variant of `Trail`. It assumes the
    # file system does not change between `find` calls. All `stat` and
    # `entries` calls are cached for the lifetime of the `Index` object.
    class Index
      # `Index#paths` is an immutable collection of `Pathname`s.
      attr_reader :paths

      # `Index#extensions` is an immutable collection of extensions.
      attr_reader :extensions

      # `Index.new` is an internal method. Instead of constructing it
      # directly, create a `Trail` and call `Trail#index`.
      def initialize(root, paths, extensions)
        @root = root

        # Freeze is used here so an error is throw if a mutator method
        # is called on the array. Mutating `@paths`, `@extensions`
        # would have unpredictable results.
        @paths      = paths.dup.freeze
        @extensions = extensions.dup.freeze
        @pathnames  = paths.map { |path| Pathname.new(path) }

        @stats    = {}
        @entries  = {}
        @patterns = {}
      end

      # `Index#root` returns root path as a `String`. This attribute is immutable.
      def root
        @root.to_s
      end

      # `Index#index` returns `self` to be compatable with the `Trail` interface.
      def index
        self
      end

      # The real implementation of `find`. `Trail#find` generates a one
      # time index and delegates here.
      #
      # See `Trail#find` for usage.
      def find(logical_path)
        base_path = Pathname.new(@root)
        logical_path = Pathname.new(logical_path.sub(/^\//, ''))

        if logical_path.to_s =~ %r{^\.\.?/}
          find_in_base_path(logical_path, base_path) { |path| return path }
        else
          find_in_paths(logical_path) { |path| return path }
        end

        nil
      end

      # A cached version of `Dir.entries` that filters out `.` files and
      # `~` swap files. Returns an empty `Array` if the directory does
      # not exist.
      def entries(path)
        @entries[path.to_s] ||= begin
          pathname = Pathname.new(path)
          if pathname.directory?
            pathname.entries.reject { |entry| entry.to_s =~ /^\.|~$|^\#.*\#$/ }.sort
          else
            []
          end
        end
      end

      # A cached version of `File.stat`. Returns nil if the file does
      # not exist.
      def stat(path)
        key = path.to_s
        if @stats.key?(key)
          @stats[key]
        elsif File.exist?(path)
          @stats[key] = File.stat(path)
        else
          @stats[key] = nil
        end
      end

      protected

      def extract_options!(arguments)
        arguments.last.is_a?(Hash) ? arguments.pop.dup : {}
      end

      # Finds logical path across all `paths`
      def find_in_paths(logical_path, &block)
        dirname, basename = logical_path.split
        @pathnames.each do |base_path|
          match(base_path.join(dirname), basename, &block)
        end
      end

      # Finds relative logical path, `../test/test_trail`. Requires a
      # `base_path` for reference.
      def find_in_base_path(logical_path, base_path, &block)
        candidate = base_path.join(logical_path)
        dirname, basename = candidate.split
        match(dirname, basename, &block) if paths_contain?(dirname)
      end

      # Checks if the path is actually on the file system and performs
      # any syscalls if necessary.
      def match(dirname, basename)
        # Potential `entries` syscall
        matches = entries(dirname)

        pattern = pattern_for(basename)
        matches = matches.select { |m| m.to_s =~ pattern }

        sort_matches(matches, basename).each do |path|
          pathname = dirname.join(path)

          # Potential `stat` syscall
          stat = stat(pathname)

          # Exclude directories
          if stat && stat.file?
            yield pathname.to_s
          end
        end
      end

      # Returns true if `dirname` is a subdirectory of any of the `paths`
      def paths_contain?(dirname)
        paths.any? { |path| dirname.to_s[0, path.length] == path }
      end

      # Cache results of `build_pattern_for`
      def pattern_for(basename)
        @patterns[basename] ||= build_pattern_for(basename)
      end

      # Returns a `Regexp` that matches the allowed extensions.
      #
      #     pattern_for("index.html") #=> /^index(.html|.htm)(.builder|.erb)*$/
      def build_pattern_for(basename)
        extension_pattern = extensions.map { |e| Regexp.escape(e) }.join('|')
        /^#{basename}(?:#{extension_pattern})*$/
      end

      # Sorts candidate matches by their extension
      # priority. Extensions in the front of the `extensions` carry
      # more weight.
      def sort_matches(matches, basename)
        matches.sort_by do |match|
          extnames = match.sub(basename.to_s, '').to_s.scan(/\.[^.]+/)
          extnames.inject(0) do |sum, ext|
            index = extensions.index(ext)
            if index
              sum + index + 1
            else
              sum
            end
          end
        end
      end
    end

    # `Trail` is the public container class for holding paths and extensions.
    class Trail
      # `Trail#paths` is a mutable `Paths` collection.
      #
      #     trail = Hike::Trail.new
      #     trail.paths.push "~/Projects/hike/lib", "~/Projects/hike/test"
      #
      # The order of the paths is significant. Paths in the beginning of
      # the collection will be checked first. In the example above,
      # `~/Projects/hike/lib/hike.rb` would shadow the existent of
      # `~/Projects/hike/test/hike.rb`.
      attr_reader :paths

      # `Trail#extensions` is a mutable `Extensions` collection.
      #
      #     trail = Hike::Trail.new
      #     trail.paths.push "~/Projects/hike/lib"
      #     trail.extensions.push ".rb"
      #
      # Extensions allow you to find files by just their name omitting
      # their extension. Is similar to Ruby's require mechanism that
      # allows you to require files with specifiying `foo.rb`.
      attr_reader :extensions

      # A Trail accepts an optional root path that defaults to your
      # current working directory. Any relative paths added to
      # `Trail#paths` will expanded relative to the root.
      def initialize(root = '.')
        @root       = Pathname.new(root).expand_path
        @paths      = []
        @extensions = []
      end

      # `Trail#root` returns root path as a `String`. This attribute is immutable.
      def root
        @root.to_s
      end

      # Append `path` to `Paths` collection
      def append_paths(*paths)
        @paths.concat(paths.map { |p| normalize_path(p) })
      end

      # Append `extension` to `Extensions` collection
      def append_extensions(*extensions)
        @extensions.concat(extensions.map { |e| normalize_extension(e) })
      end

      # `Trail#find` returns a the expand path for a logical path in the
      # path collection.
      #
      #     trail = Hike::Trail.new "~/Projects/hike"
      #     trail.extensions.push ".rb"
      #     trail.paths.push "lib", "test"
      #
      #     trail.find "hike/trail"
      #     # => "~/Projects/hike/lib/hike/trail.rb"
      #
      #     trail.find "test_trail"
      #     # => "~/Projects/hike/test/test_trail.rb"
      #
      def find(*args, &block)
        index.find(*args, &block)
      end

      # `Trail#index` returns an `Index` object that has the same
      # interface as `Trail`. An `Index` is a cached `Trail` object that
      # does not update when the file system changes. If you are
      # confident that you are not making changes the paths you are
      # searching, `index` will avoid excess system calls.
      #
      #     index = trail.index
      #     index.find "hike/trail"
      #     index.find "test_trail"
      #
      def index
        Index.new(root, paths, extensions)
      end

      # `Trail#entries` is equivalent to `Dir#entries`. It is not
      # recommend to use this method for general purposes. It exists for
      # parity with `Index#entries`.
      def entries(path)
        pathname = Pathname.new(path)
        if pathname.directory?
          pathname.entries.reject { |entry| entry.to_s =~ /^\.|~$|^\#.*\#$/ }.sort
        else
          []
        end
      end

      # `Trail#stat` is equivalent to `File#stat`. It is not
      # recommend to use this method for general purposes. It exists for
      # parity with `Index#stat`.
      def stat(path)
        if File.exist?(path)
          File.stat(path.to_s)
        else
          # nil
        end
      end

      private

      def normalize_extension(ext)
        ext.start_with?('.') ? ext : ".#{ext}"
      end

      def normalize_path(path)
        path = Pathname.new(path)
        path = @root.join(path) if path.relative?
        path.expand_path.to_s
      end
    end
  end
end
