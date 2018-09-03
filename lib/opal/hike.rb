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

    # `NormalizedArray` is an internal abstract wrapper class that calls
    # a callback `normalize_element` anytime an element is added to the
    # Array.
    #
    # `Extensions` and `Paths` are subclasses of `NormalizedArray`.
    class NormalizedArray < Array
      def initialize
        super()
      end

      def []=(*args)
        value = args.pop

        if value.respond_to?(:to_ary)
          value = normalize_elements(value)
        else
          value = normalize_element(value)
        end

        super(*args.concat([value]))
      end

      def <<(element)
        super normalize_element(element)
      end

      def collect!
        super do |element|
          result = yield element
          normalize_element(result)
        end
      end

      alias_method :map!, :collect!

      def insert(index, *elements)
        super index, *normalize_elements(elements)
      end

      def push(*elements)
        super(*normalize_elements(elements))
      end

      def replace(elements)
        super normalize_elements(elements)
      end

      def unshift(*elements)
        super(*normalize_elements(elements))
      end

      def normalize_elements(elements)
        elements.map do |element|
          normalize_element(element)
        end
      end
    end

    # `Index` is an internal cached variant of `Trail`. It assumes the
    # file system does not change between `find` calls. All `stat` and
    # `entries` calls are cached for the lifetime of the `Index` object.
    class Index
      # `Index#paths` is an immutable `Paths` collection.
      attr_reader :paths

      # `Index#extensions` is an immutable `Extensions` collection.
      attr_reader :extensions

      # `Index#aliases` is an immutable `Hash` mapping an extension to
      # an `Array` of aliases.
      attr_reader :aliases

      # `Index.new` is an internal method. Instead of constructing it
      # directly, create a `Trail` and call `Trail#index`.
      def initialize(root, paths, extensions, aliases)
        @root = root

        # Freeze is used here so an error is throw if a mutator method
        # is called on the array. Mutating `@paths`, `@extensions`, or
        # `@aliases` would have unpredictable results.
        @paths      = paths.dup.freeze
        @extensions = extensions.dup.freeze
        @aliases    = aliases.inject({}) { |h, (k, a)|
                        h[k] = a.dup.freeze; h
                     }.freeze
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
      def find(*logical_paths, &block)
        if block_given?
          options = extract_options!(logical_paths)
          base_path = Pathname.new(options[:base_path] || @root)

          logical_paths.each do |logical_path|
            logical_path = Pathname.new(logical_path.sub(/^\//, ''))

            if relative?(logical_path)
              find_in_base_path(logical_path, base_path, &block)
            else
              find_in_paths(logical_path, &block)
            end
          end

          nil
        else
          find(*logical_paths) do |path|
            return path
          end
        end
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

        def relative?(logical_path)
          logical_path.to_s =~ /^\.\.?\//
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
          extname = basename.extname
          aliases = find_aliases_for(extname)

          if aliases.any?
            basename = basename.basename(extname)
            aliases  = [extname] + aliases
            aliases_pattern = aliases.map { |e| Regexp.escape(e) }.join("|")
            basename_re = Regexp.escape(basename.to_s) + "(?:#{aliases_pattern})"
          else
            basename_re = Regexp.escape(basename.to_s)
          end

          extension_pattern = extensions.map { |e| Regexp.escape(e) }.join("|")
          /^#{basename_re}(?:#{extension_pattern})*$/
        end

        # Sorts candidate matches by their extension
        # priority. Extensions in the front of the `extensions` carry
        # more weight.
        def sort_matches(matches, basename)
          aliases = find_aliases_for(basename.extname)

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

        def find_aliases_for(extension)
          @aliases.inject([]) do |aliases, (key, value)|
            aliases.push(key) if value == extension
            aliases
          end
        end
    end

    # `Extensions` is an internal collection for tracking extension names.
    class Extensions < NormalizedArray
      # Extensions added to this array are normalized with a leading
      # `.`.
      #
      #     extensions << "js"
      #     extensions << ".css"
      #
      #     extensions
      #     # => [".js", ".css"]
      #
      def normalize_element(extension)
        if extension[/^\./]
          extension
        else
          ".#{extension}"
        end
      end
    end

    # `Paths` is an internal collection for tracking path strings.
    class Paths < NormalizedArray
      def initialize(root = ".")
        @root = Pathname.new(root)
        super()
      end

      # Relative paths added to this array are expanded relative to `@root`.
      #
      #     paths = Paths.new("/usr/local")
      #     paths << "tmp"
      #     paths << "/tmp"
      #
      #     paths
      #     # => ["/usr/local/tmp", "/tmp"]
      #
      def normalize_element(path)
        path = Pathname.new(path)
        path = @root.join(path) if path.relative?
        path.expand_path.to_s
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

      # `Index#aliases` is a mutable `Hash` mapping an extension to
      # an `Array` of aliases.
      #
      #   trail = Hike::Trail.new
      #   trail.paths.push "~/Projects/hike/site"
      #   trail.aliases['.htm']   = 'html'
      #   trail.aliases['.xhtml'] = 'html'
      #   trail.aliases['.php']   = 'html'
      #
      # Aliases provide a fallback when the primary extension is not
      # matched. In the example above, a lookup for "foo.html" will
      # check for the existence of "foo.htm", "foo.xhtml", or "foo.php".
      attr_reader :aliases

      # A Trail accepts an optional root path that defaults to your
      # current working directory. Any relative paths added to
      # `Trail#paths` will expanded relative to the root.
      def initialize(root = ".")
        @root       = Pathname.new(root).expand_path
        @paths      = Paths.new(@root)
        @extensions = Extensions.new
        @aliases    = Hash.new { |h, k| h[k] = Extensions.new }
      end

      # `Trail#root` returns root path as a `String`. This attribute is immutable.
      def root
        @root.to_s
      end

      # Prepend `path` to `Paths` collection
      def prepend_paths(*paths)
        self.paths.unshift(*paths)
      end
      alias_method :prepend_path, :prepend_paths

      # Append `path` to `Paths` collection
      def append_paths(*paths)
        self.paths.push(*paths)
      end
      alias_method :append_path, :append_paths

      # Remove `path` from `Paths` collection
      def remove_path(path)
        self.paths.delete(path)
      end

      # Prepend `extension` to `Extensions` collection
      def prepend_extensions(*extensions)
        self.extensions.unshift(*extensions)
      end
      alias_method :prepend_extension, :prepend_extensions

      # Append `extension` to `Extensions` collection
      def append_extensions(*extensions)
        self.extensions.push(*extensions)
      end
      alias_method :append_extension, :append_extensions

      # Remove `extension` from `Extensions` collection
      def remove_extension(extension)
        self.extensions.delete(extension)
      end

      # Alias `new_extension` to `old_extension`
      def alias_extension(new_extension, old_extension)
        aliases[normalize_extension(new_extension)] = normalize_extension(old_extension)
      end

      # Remove the alias for `extension`
      def unalias_extension(extension)
        aliases.delete(normalize_extension(extension))
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
      # `find` accepts multiple fallback logical paths that returns the
      # first match.
      #
      #     trail.find "hike", "hike/index"
      #
      # is equivalent to
      #
      #     trail.find("hike") || trail.find("hike/index")
      #
      # Though `find` always returns the first match, it is possible
      # to iterate over all shadowed matches and fallbacks by supplying
      # a block.
      #
      #     trail.find("hike", "hike/index") { |path| warn path }
      #
      # This allows you to filter your matches by any condition.
      #
      #     trail.find("application") do |path|
      #       return path if mime_type_for(path) == "text/css"
      #     end
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
        Index.new(root, paths, extensions, aliases)
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
          nil
        end
      end

      private
        def normalize_extension(extension)
          if extension[/^\./]
            extension
          else
            ".#{extension}"
          end
        end
    end
  end
end
