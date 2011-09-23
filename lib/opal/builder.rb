require 'fileutils'
require 'opal/parser'

module Opal

  # The Builder class is used for building single ruby sources, or
  # building the core library ready for the browser/v8 context. It
  # is not used directly for building packages.
  class Builder

    OPAL_PATH = File.expand_path(File.join('..', '..', '..'), __FILE__)

    STDLIB_PATH = File.join OPAL_PATH, 'stdlib'

    RUNTIME_PATH = File.join OPAL_PATH, 'runtime'

    CORE_PATH = File.join OPAL_PATH, 'corelib'

    def initialize
      @parser = Parser.new
    end

    def parse(source, options = {})
      @parser.parse source, options
    end

    # Returns the result of the compiled file ready for opal to load.
    #
    # `relative_path` is used for the name the built file should have.
    # This is used for building a singular rb or js file into the
    # compiled output, and will avoid the user's dir setup being exposed
    # in production code. It will be of the form
    # `lib/some_lib/some_lib.rb`
    #
    # @param [String] full_path The full pathname to the file to build
    # @paeam [String] relative_path The pathname to be used in the build
    # file.
    #
    # @return [String]
    def wrap_source(full_path, relative_path = nil)
      relative_path ||= full_path
      ext = File.extname full_path
      # relative_path = relative_path.sub(/\.rb/, '.js') if ext == '.rb'
      content = compile_source full_path

      "opal.lib('#{relative_path}.rb', #{content});\n"
    end

    # Simply compile the given source code at the given path. This is
    # for compiling ruby or javascript sources only. This can be used
    # for any method that builds for the browser.
    #
    # @param [String] full_path location of the source to build
    # @return [String] compiled source
    def compile_source(full_path)
      ext = File.extname full_path
      src = File.read full_path

      case ext
      when '.js'
        "function($rb, self, __FILE__) { #{src} }"

      when '.rb'
        return parse src

      else
        raise "Bad file type for wrapping. Must be ruby or javascript"
      end
    end

    # Builds core opal runtime + core libs, and returns as a string.
    # This can then just be used directly by any compiled code. The
    # core lib is then auto loaded so it is ready for running.
    def build_core
      code = ''

      %w[pre runtime init class module fs loader].each do |f|
        code += File.read(File.join RUNTIME_PATH, f + '.js')
      end

      order = File.read(File.join(CORE_PATH, 'load_order')).strip.split

      core = order.map do |o|
        File.read File.join(CORE_PATH, o + '.rb')
      end

      code += "var core_lib = #{parse core.join};"

      code + File.read(File.join RUNTIME_PATH, 'post.js')
    end

    # Builds the opal parser and dev.rb file, and returns as a string.
    def build_parser
      code = ''

      %w[opal/nodes opal/lexer opal/parser].each do |src|
        full = File.join OPAL_PATH, 'lib', src + '.rb'
        compiled = compile_source full
        code += "opal.lib('#{src}.rb', #{compiled});"
      end

      code += build_stdlib 'racc/parser', 'strscan', 'dev'
      code += "opal.require('dev');"

      code
    end

    # Build the given sources from the standard library. These can be
    # globs. Returns a string of all content.
    def build_stdlib(*files)
      code = []
      Dir.chdir(STDLIB_PATH) do
        files.each do |file|
          lib = Dir[file + '.rb']
          full_path = File.join STDLIB_PATH, lib.first
          code << wrap_source(full_path, file)
        end
      end

      code.join ''
    end

    # Takes a hash of build options.
    #
    # :project_dir - The base directory to work in. If not given then cwd is used.
    #
    # :files - May be a single source, a directory, or an array of ruby/js src
    #
    # :out - The output file. All sources are built into a single output file.
    # If this is not given, it will default to project_dir/javascripts/name.js
    # where name is the basename of the given project_dir or cwd.
    #
    # :main - only useful when more than one input is given to determine which
    # file is automatically loaded on running in the browser.
    #
    # :watch - watch all sources and automatically recompile if one changes
    #
    # :pre - pre content to add. Could be copyright, or extra code etc
    #
    # :post - post content.. could be extra code etc
    #
    # Also, if no output is given, then one file will be used for all sources,
    # and the files name will be taken as the basename of the root_dir/cwd.
    #
    # @param {Hash} options Build options to use
    def build(options = {})
      files = options[:files] || []
      files = [files] unless files.is_a? Array
      options[:files] = files = Dir.[](*files)

      raise "Opal::Builder - No input files could be found" if files.empty?

      main = options[:main]

      if main == true
        options[:main] = files.first
      elsif main
        raise "Opal::Builder - Main file does not exist!" unless File.exists? main
        files << main unless files.include? main
      elsif main == false
        options[:main] = false
      else
        options[:main] = files.first
      end

      main = options[:main]

      unless options[:out]
        options[:out] = main.sub /\.rb$/, '.js'
      end

      FileUtils.mkdir_p File.dirname(options[:out])

      rebuild options
      if options[:watch]
        puts "Watching for changes.."
        loop do
          out_mtime = File.stat(options[:out]).mtime
          options[:files].each do |file|
            if File.stat(file).mtime > out_mtime
              puts "#{Time.now} rebuilding - changes detected in #{file}"
              rebuild options
            end
          end

          begin
            sleep 1
          rescue Interrupt
            exit 0
          end
        end
      end
    end

    private

    # Does the actual rebuild of a project
    def rebuild(options)
      puts "rebuilding to #{options[:out]}"
      puts options[:files].inspect
      File.open(options[:out], 'w') do |out|
        # out.write @pre if @pre

        options[:files].each do |file|
          out.write wrap_source file
        end

        if options[:main]
          main = options[:main].sub(/\.rb$/, '')
          out.write "opal.require('#{main}');\n"
        end

        # out.write @post if @post
      end
    end
  end
end

