require 'opal'
require 'rack'
require 'opal/builder'
require 'opal/cli_runners'

module Opal
  class CLI
    attr_reader :options, :file, :compiler_options, :evals, :load_paths, :argv,
                :output, :requires, :gems, :stubs, :verbose, :port, :preload,
                :filename, :debug, :no_exit

    def compile?
      @compile
    end

    def sexp?
      @sexp
    end

    def skip_opal_require?
      @skip_opal_require
    end

    class << self
      attr_accessor :stdout
    end

    def initialize options = nil
      options ||= {}

      # Runner
      @runner_type = options.delete(:runner)    || :nodejs
      @port       = options.delete(:port)       || 3000

      @options    = options
      @compile    = !!options.delete(:compile)
      @sexp       = options.delete(:sexp)
      @file       = options.delete(:file)
      @no_exit    = options.delete(:no_exit)
      @argv       = options.delete(:argv)       || []
      @evals      = options.delete(:evals)      || []
      @requires   = options.delete(:requires)   || []
      @load_paths = options.delete(:load_paths) || []
      @gems       = options.delete(:gems)       || []
      @stubs      = options.delete(:stubs)      || []
      @preload    = options.delete(:preload)    || []
      @output     = options.delete(:output)     || self.class.stdout || $stdout
      @verbose    = options.fetch(:verbose, false); options.delete(:verbose)
      @debug      = options.fetch(:debug, false);   options.delete(:debug)
      @filename   = options.fetch(:filename) { @file && @file.path }; options.delete(:filename)
      @skip_opal_require = options.delete(:skip_opal_require)
      @compiler_options = Hash[
        *compiler_option_names.map do |option|
          key = option.to_sym
          next unless options.has_key? key
          value = options.delete(key)
          [key, value]
        end.compact.flatten
      ]

      raise ArgumentError, "no runnable code provided (evals or file)" if @evals.empty? and @file.nil?
      raise ArgumentError, "unknown options: #{options.inspect}" unless @options.empty?
    end

    def run
      case
      when sexp?;    show_sexp
      when compile?; show_compiled_source
      else           run_code
      end
    end

    def runner
      @runner ||= case @runner_type
                  when :server;      CliRunners::Server.new(output, port)
                  when :nodejs;      CliRunners::Nodejs.new(output)
                  when :phantomjs;   CliRunners::Phantomjs.new(output)
                  when :applescript; CliRunners::AppleScript.new(output)
                  else raise ArgumentError, @runner_type.inspect
                  end
    end

    def run_code
      runner.run(compiled_source, argv)
      @exit_status = runner.exit_status
    end

    attr_reader :exit_status

    def compiled_source
      Opal.paths.concat load_paths
      gems.each { |gem_name| Opal.use_gem gem_name }

      builder = Opal::Builder.new stubs: stubs, compiler_options: compiler_options

      builder.build 'opal' unless skip_opal_require?

      preload.each { |path| builder.build_require(path) }

      # FLAGS
      builder.build_str '$VERBOSE = true', '(flags)' if verbose
      builder.build_str '$DEBUG = true', '(flags)' if debug

      # REQUIRES: -r
      requires.each do |local_require|
        builder.build(local_require)
      end

      if evals.any?
        builder.build_str(evals.join("\n"), '-e')
      else
        if file and (filename != '-' or evals.empty?)
          builder.build_str(file.read, filename)
        end
      end

      builder.build_str 'Kernel.exit', '(exit)' unless no_exit

      builder.to_s
    end

    def show_compiled_source
      puts compiled_source
    end

    def show_sexp
      if evals.any?
        sexp = Opal::Parser.new.parse(evals.join("\n"), '-e')
      else
        if file and (file.path != '-' or evals.empty?)
          sexp = Opal::Parser.new.parse(file.read, file.path)
        end
      end
      puts sexp.inspect
    end

    def map
      compiler = Opal::Compiler.compile(file.read, options.merge(:file => file.path))
      compiler.compile
      compiler.source_map
    end

    def compiler_option_names
      %w[
        method_missing
        arity_check
        dynamic_require_severity
        source_map_enabled
        irb_enabled
        inline_operators
        template
      ]
    end

    def puts(*args)
      output.puts(*args)
    end

  end
end
