require 'opal'
require 'rack'
require 'opal/builder'

module Opal
  class CLI
    attr_reader :options, :filename
    attr_reader :evals, :load_paths, :output, :requires, :gems

    class << self
      attr_accessor :stdout
    end

    def initialize options = nil
      options ||= {}
      @options    = options
      @evals      = options.delete(:evals) || []
      @requires   = options.delete(:requires) || []
      @filename   = options.delete(:filename)
      @load_paths = options.delete(:load_paths) || []
      @gems       = options.delete(:gems) || []
      @output     = options.delete(:output) || self.class.stdout || $stdout
      raise ArgumentError, "no runnable code provided (evals or filename)" if @evals.empty? and @filename.nil?
      raise ArgumentError, "unknown options: #{options.inspect}" unless @options.empty?
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

    def run_code
      full_source = compiled_source
      run_with_node(full_source)
    end

    def compiled_source include_opal = true
      Opal.paths.concat load_paths
      gems.each do |gem_name|
        Opal.use_gem gem_name
      end

      builder = Opal::Builder.new
      _requires = []
      full_source = []
      builder_options = {:prerequired => _requires}

      # REQUIRES: -r
      local_requires = []
      local_requires << 'opal' if include_opal
      local_requires += requires
      if local_requires.any?
        requires_source = local_requires.map { |r| "require #{r.inspect}" }.join("\n")
        full_source << builder.build_str(requires_source, '-r', builder_options)
      end

      # EVALS: -e
      evals.each_with_index do |code, index|
        file = "-e#{index}"
        full_source << builder.build_str(code, file, builder_options)
      end

      # FILE: ARGF
      if filename
        full_source << builder.build(filename, builder_options)
      end

      full_source.map(&:to_s).join("\n")
    end

    def run_with_node(code)
      require 'open3'
      begin
        stdin, stdout, stderr = Open3.popen3('node')
      rescue Errno::ENOENT
        raise MissingNodeJS, 'Please install Node.js to be able to run Opal scripts.'
      end

      stdin.write code
      stdin.close

      [stdout, stderr].each do |io|
        str = io.read
        puts str unless str.empty?
      end
    end

    class MissingNodeJS < StandardError
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
      puts compiled_source(false)
    end

    def show_sexp
      puts sexp.inspect
    end



    # PROCESSOR

    def set_processor_options
      processor_options.each do |option|
        key = option.to_sym
        next unless options.has_key? key
        Opal::Processor.send("#{option}=", options[key])
      end
    end

    def map
      compiler = Opal::Compiler.new(filename, options)
      compiler.compile
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
      @server ||= Opal::Server.new do |s|
        load_paths.each do |path|
          s.append_path path
        end
        s.main = File.basename(filename, '.rb')
      end
    end

    ##
    # OUTPUT

    def puts(*args)
      output.puts(*args)
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
