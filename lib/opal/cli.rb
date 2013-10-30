require 'opal'
require 'rack'

module Opal
  class CLI
    attr_reader :options, :filename
    attr_reader :evals, :load_paths, :output, :requires

    class << self
      attr_accessor :stdout
    end

    def initialize options = nil
      options ||= {}
      @options    = options
      @evals      = options[:evals] || []
      @requires   = options[:requires] || []
      @filename   = options[:filename]
      @load_paths = options[:load_paths] || []
      @output     = options[:output] || self.class.stdout || $stdout
      raise ArgumentError if @evals.empty? and @filename.nil?
    end

    def run
      set_processor_options

      case
      when options[:sexp];    prepare_eval_code; show_sexp
      when options[:compile]; prepare_eval_code; show_compiled_source
      when options[:server];  prepare_eval_code; start_server
      else                    run_code
      end
    end




    # RUN CODE

    class PathFinder < Struct.new(:paths)
      def find(filename)
        full_path = nil
        _path = paths.find do |path|
          full_path = File.join(path, filename)
          File.exist? full_path
        end
        full_path or raise(ArgumentError, "file: #{filename} not found")
      end
    end

    def run_code
      Opal.paths.concat load_paths
      path_finder = PathFinder.new(Opal.paths)
      builder = Opal::Builder.new
      full_source = builder.build('opal')

      require 'pathname'
      requires.each do |path|
        path   = Pathname(path)
        path   = Pathname(path_finder.find(path)) unless path.absolute?
        full_source << builder.build_str(path.read, :file => path.to_s)
      end

      evals.each_with_index do |code, index|
        full_source << builder.build_str(code, :file => "(eval #{index+1})")
      end

      file = Pathname(filename.to_s)
      full_source << builder.build_str(file.read, :file => file.to_s) if file.exist?

      run_with_node(full_source)
    end

    def run_with_node(code)
      require 'open3'
      begin
        stdin, stdout, stderr = Open3.popen3('node')
      rescue Errno::ENOENT
        raise MissingNode, 'Please install Node.js to be able to run Opal scripts.'
      end

      stdin.write code
      stdin.close

      [stdout, stderr].each do |io|
        str = io.read
        puts str unless str.empty?
      end
    end

    class MissingNode < StandardError
    end

    def start_server
      require 'rack'
      require 'webrick'
      require 'logger'

      Rack::Server.start(
        :app       => server,
        :Port      => options[:port] || 3000,
        :AccessLog => [],
        :Logger    => Logger.new($stdout)
      )
    end

    def show_compiled_source
      if sprockets[filename]
        puts sprockets[filename].to_a.last
      elsif File.exist?(filename)
        puts Opal.compile File.read(filename), options
      else
        puts Opal.compile(filename, options)
      end
    end

    def show_sexp
      puts sexp.inspect
    end



    # PROCESSOR

    def set_processor_options
      require_opal_sprockets
      processor_options.each do |option|
        key = option.to_sym
        next unless options.has_key? key
        Opal::Processor.send("#{option}=", options[key])
      end
    end

    def map
      compiler = Opal::Compiler.new
      compiler.compile(filename, options)
      compiler.source_map
    end

    def source
      File.exist?(filename) ? File.read(filename) : filename
    end

    def processor_options
      %w[
        method_missing_enabled
        arity_check_enabled
        const_missing_enabled
        dynamic_require_severity
        source_map_enabled
        irb_enabled
      ]
    end

    ##
    # SPROCKETS

    def sprockets
      server.sprockets
    end

    def server
      require_opal_sprockets
      @server ||= Opal::Server.new do |s|
        load_paths.each do |path|
          s.append_path path
        end
        s.main = File.basename(filename, '.rb')
      end
    end

    def require_opal_sprockets
      begin
        require 'opal-sprockets'
      rescue LoadError
        $stderr.puts 'Opal executable requires opal-sprockets to be fully functional.'
        $stderr.puts 'You can install it with rubygems:'
        $stderr.puts ''
        $stderr.puts '    gem install opal-sprockets'
        exit -1
      end
    end

    ##
    # OUTPUT

    def puts *args
      output.puts *args
    end

    ##
    # EVALS

    def evals_source
      evals.inject('', &:<<)
    end

    def prepare_eval_code
      if evals.any?
        require 'tmpdir'
        path = File.join(Dir.mktmpdir,"opal-#{$$}.js.rb")
        File.open(path, 'w') do |tempfile|
          load_paths << File.dirname(path)
          tempfile.puts 'require "opal"'
          tempfile.puts evals_source
        end
        @filename = File.basename(path)
      end
    end

    ##
    # SOURCE

    def sexp
      Opal::Parser.new.parse(source)
    end
  end
end
