#### Opal Builder
#
# Builder class is used to build one or more ruby files into a combined
# output script. The simplest form would be building a single ruby file
# back into the current working dir:
#
#     Opal::Builder.new(:files => 'foo.rb')
#
# Which would create two files, `foo.js` and `foo.debug.js` to be used
# in release and debug environments respectively.
#
# In real world scenarios, Builder will be used to build entire
# directories. This is achieved just as easily:
#
#     Opal::Builder.new(:files => 'my_libs')
#
# Where `my_libs` is a directory. This will create a `my_libs.js` and
# `my_libs.debug.js` file in the current directory.
#
# As a special case, when building the `lib` directory, the basename of
# the current working directory (assumed to be the app/gem name) will be
# used to construct the output name:
#
#     # in dir ~/dev/vienna
#     Opal::Builder.new(:files => 'lib')
#
# This creates the specially named `vienna.js` and `vienna.debug.js`.
#
# As a second special case, building a `spec` or `test` directory will
# append `test` to the basename of the current directory to name the
# output files.
#
# A custom output destination can be specified using the `:out` option
# which should point to the output file for the release build mode. The
# debug output will prefix the extname with `.debug`:
#
#     Opal::Builder.new(:files => 'lib', :out => 'vienna-0.1.0.js')
#
# This will give you `vienna-0.1.0.js` and `vienna-0.1.0.debug.js`.
#
# If no input files are specified, then `Builder` will automatically
# build the `lib/` directory.
#
#     Opal::Builder.new.build
#

# FileUtils are useful for making sure output directory exists.
require 'fileutils'

module Opal
  # `Builder.new` takes an optional hash of options to control which
  # files to build and to where. The `options` hash takes these options:
  #
  # * `:files`: specifies an array (or single string) of files/directories
  #   to recursively build. _Defaults to `['lib']`_.
  #
  # * `:out`: the file to write the result to. When building a debug build
  #   as well, 'debug' will be injected before the extname. Defaults to the
  #   first file name.
  class Builder
    def initialize(options = {})
      @sources = Array(options[:files])
      @options = options
    end

    def build
      release_out = nil
      debug_out   = nil

      raise "No files given" if @sources.empty?

      if out = @options[:out]
        release_out = out
        debug_out = out.chomp(File.extname(out)) + '.debug.js'
      else
        if @sources == ['lib']
          out = File.basename(Dir.getwd)
        elsif @sources.include? 'spec'
          out = File.basename(Dir.getwd) + '.test'
        elsif @sources.size == 1
          out = File.basename(@sources[0], '.*')
        else
          out = File.basename(@sources[0], '.*')
        end

        release_out = out + '.js'
        debug_out   = out + '.debug.js'
      end

      puts "[#{File.basename(Dir.getwd)}] sources: [#{@sources.join ', '}] (#{release_out}, #{debug_out})"

      FileUtils.mkdir_p File.dirname(release_out)

      files = files_for @sources

      build_to release_out, files, false
      build_to debug_out, files, true
    end

    # Returns an array of all ruby source files to build from the given
    # sources array. The passed sources can be files or directories, where
    # directories will be globbed for all ruby sources.
    # @param [Array<String>] sources array of files/dirs to build
    # @return [Array<String>]
    def files_for(sources)
      files = []

      sources.each do |s|
        if File.directory? s
          files.push *Dir[File.join s, '**/*.rb']
        elsif File.extname(s) == '.rb'
          files << s
        end
      end

      files
    end

    def build_to(out, files, debug)
      @parser    = Parser.new(:debug => debug)

      File.open(out, 'w+') do |o|
        # In debug mode, make sure opal runtime is also debug mode
        if debug
          o.puts "if (!opal.debug) {"
          o.puts "  throw new Error('This file requires opal.debug.js');"
          o.puts "}"
        end

        files.each { |path| o.write build_file(path) }
      end
    end

    # Build an individual file at the given path, and return a wapped result
    # used to register the factory with the opal runtime. The parser used
    # will be the one set in `#build_to`.
    #
    # @example
    #
    #     builder.build_file 'lib/foo.rb'
    #     # => "opal.lib('foo', function() { ... });
    #
    #     builder.build_file 'spec/foo_spec.rb'
    #     # => "opal.file('/spec/foo_spec.rb', function() { ... });
    #
    # @param [String] path relative path to the file to be built
    # @return [String] factory wrapped compiled code
    def build_file(path)
      code = @parser.parse File.read(path), path
      path = path.chomp '.rb'
      path = path[4..-1] if /^lib/ =~ path

      "opal.file('#{path}', #{code});\n"
    end
  end
end
