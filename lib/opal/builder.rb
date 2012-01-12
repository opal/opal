require 'fileutils'

module Opal
  class Builder
    def initialize(sources, options = {})
      @sources = Array(sources)
      @options = options
    end

    def build
      release_out = nil
      debug_out   = nil

      raise "No files given" if @sources.empty?

      puts "given output #{@options[:out]}"

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
      code  = @parser.parse File.read(path), path

      if /^lib/ =~ path
        "opal.lib('#{path[4..-4]}', function() {\n#{code}\n});\n"
      else
        "opal.file('/#{path}', function() {\n#{code}\n});\n"
      end
    end
  end
end
