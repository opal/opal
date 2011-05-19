require 'fileutils'

module Opal
  # Builder is used for compiling simple ruby files into javascript files
  # through the command line or a rake task. It is used for non bundle based
  # building systems, and is meant for building small scale pages rather than
  # applications.
  class Builder
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
    def initialize(options = {})
      @project_dir = options[:project_dir] || Dir.getwd
      @project_name = File.basename @project_dir

      files = options[:files] || []
      files = [files] unless files.is_a? Array
      @files = Dir.[](*files)

      @watch = options[:watch]

      raise "Opal::Builder - No input files could be found!" if @files.empty?

      @main = options[:main]

      if @main == true
        @main = @files.first
      elsif @main
        raise "Opal::Builder - Main file does not exist!" unless File.exists? @main
        @files << @main unless @files.include? @main
      else
        @main = false
      end

      @pre = options[:pre]
      @post = options[:post]

      out = options[:out]

      unless out or @main
        File.basename(@main, '.rb') + '.js'
      end

      @out = File.join @project_dir, out
      FileUtils.mkdir_p File.dirname(@out)
    end

    # Actually build the simple builder. This is simply used as a looper to
    # rebuild if a source file changes. The trigger for a rebuild is when a
    # source file changes. So on each loop, we check if any source file has
    # a newer mtime than the destination file.
    def build
      rebuild
      if @watch
        puts "Watching for changes.."
        loop do
          out_mtime = File.stat(@out).mtime
          @files.each do |file|
            if File.stat(file).mtime > out_mtime
              puts "#{Time.now} rebuilding - changes detected in #{file}"
              rebuild
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

    # Does the actual rebuild of a project
    def rebuild
      puts "rebuilding to #@out"
      puts @files.inspect
      File.open(@out, 'w') do |out|
        out.write @pre if @pre

        @files.each do |file|
          out.write wrap_source file
        end

        if @main
          main = File.basename(@main).sub(/\.rb/, '')
          out.write "opal.require('#{main}');\n"
        end

        out.write @post if @post
      end
    end

    # Returns the result of the compiled file ready for opal to load
    #
    # @return {String}
    def wrap_source(path)
      ext_name = File.extname path

      content = case ext_name
      when '.js'
        source = File.read path
        "function($runtime, self, __FILE__) { #{source} }"

      when '.rb'
        source = Opal::RubyParser.new(File.read(path)).parse!.generate_top
        path = path.sub(/\.rb/, '.js')
        "function($runtime, self, __FILE__) { #{source} }"

      else
        raise "Bad file type for wrapping. Must be ruby or javascript"
      end

      # "opal.register('#{File.basename path}', #{content});\n"
      "opal.register('#{path}', #{content});\n"
    end
  end
end

