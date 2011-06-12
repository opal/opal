require 'fileutils'
require 'opal/build_methods'

module Opal
  # Builder is used for compiling simple ruby files into javascript files
  # through the command line or a rake task. It is used for non bundle based
  # building systems, and is meant for building small scale pages rather than
  # applications.
  class Builder
    include BuildMethods

    OPAL_PATH = File.expand_path(File.join('..', '..', '..'), __FILE__)

    STDLIB_PATH = File.join OPAL_PATH, 'lib'

    RUNTIME_PATH = File.join OPAL_PATH, 'runtime.js'

    # Builds core opal runtime + core libs, and returns as a string.
    # This can then just be used directly by any compiled code. The
    # core lib is then auto loaded so it is ready for running.
    def build_core
      code = ''

      code += File.read(RUNTIME_PATH)
      code += build_stdlib('core.rb', 'core/*.rb')
      code += "opal.require('core');"

      code
    end

    # Builds the opal parser and dev.rb file, and returns as a string.
    def build_parser
      code = ''

      %w[opal/ruby/nodes opal/ruby/parser opal/ruby/ruby_parser].each do |src|
        full = File.join OPAL_PATH, 'opal_lib', src + '.rb'
        compiled = compile_source full
        code += "opal.register('#{src}.rb', #{compiled});"
      end

      code += build_stdlib 'racc/parser.rb', 'strscan.rb', 'dev.rb'
      code += "opal.require('dev');"

      code
    end

    # Build the given sources from the standard library. These can be
    # globs. Returns a string of all content.
    def build_stdlib(*files)
      code = []

      Dir.chdir(STDLIB_PATH) do
        Dir.[](*files).each do |lib|
          full_path = File.join STDLIB_PATH, lib
          code << wrap_source(full_path, lib)
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

