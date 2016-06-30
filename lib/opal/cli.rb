require 'opal'
require 'rack'
require 'opal/builder'
require 'opal/compiler'
require 'opal/cli_runners'

module Opal
  class CLI
    attr_reader :options, :file, :compiler_options, :evals, :load_paths, :argv,
                :output, :requires, :gems, :stubs, :verbose, :port, :preload,
                :filename, :debug, :no_exit, :lib_only

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

      @options     = options
      @compile     = !!options.delete(:compile)
      @sexp        = options.delete(:sexp)
      @file        = options.delete(:file)
      #print options;
      @map         = options.delete(:map)
      if (@map)
        map()
      end
      @no_exit     = options.delete(:no_exit)
      @lib_only    = options.delete(:lib_only)
      @argv        = options.delete(:argv)       || []
      @evals       = options.delete(:evals)      || []
      @requires    = options.delete(:requires)   || []
      @load_paths  = options.delete(:load_paths) || []
      @gems        = options.delete(:gems)       || []
      @stubs       = options.delete(:stubs)      || []
      @preload     = options.delete(:preload)    || []
      @output      = options.delete(:output)     || self.class.stdout || $stdout
      @verbose     = options.fetch(:verbose, false); options.delete(:verbose)
      @debug       = options.fetch(:debug, false);   options.delete(:debug)
      @filename    = options.fetch(:filename) { @file && @file.path }; options.delete(:filename)
      @skip_opal_require = options.delete(:skip_opal_require)
      @compiler_options = Hash[
        *compiler_option_names.map do |option|
          key = option.to_sym
          next unless options.has_key? key
          value = options.delete(key)
          [key, value]
        end.compact.flatten
      ]

      raise ArgumentError, "no runnable code provided (evals or file)" if @evals.empty? and @file.nil? and not(@lib_only)
      raise ArgumentError, "can't accept evals or file in `library only` mode" if (@evals.any? or @file) and @lib_only
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
      @runner ||= begin
        const_name = @runner_type.to_s.capitalize
        CliRunners.const_defined?(const_name) or
          raise ArgumentError, "unknown runner: #{@runner_type.inspect}"
        CliRunners.const_get(const_name).new(output: output, port: port)
      end
    end

    def run_code
      runner.run(compiled_source, argv)
      @exit_status = runner.exit_status
    end

    attr_reader :exit_status

    def build
      builder = Opal::Builder.new stubs: stubs, compiler_options: compiler_options
      builder.append_paths(*load_paths)
      gems.each { |gem_name| builder.use_gem gem_name }

      builder.build 'opal' unless skip_opal_require?

      preload.each { |path| builder.build_require(path) }

      # FLAGS
      builder.build_str '$VERBOSE = true', '(flags)' if verbose
      builder.build_str '$DEBUG = true', '(flags)' if debug

      # REQUIRES: -r
      requires.each do |local_require|
        builder.build(local_require)
      end

      unless lib_only
        evals_or_file do |contents, filename|
          builder.build_str(contents, filename)
        end
      end

      builder.build_str 'Kernel.exit', '(exit)' unless no_exit

      builder
    end

    def compiled_source
      build.to_s
    end

    def show_compiled_source
      puts compiled_source
    end

    def show_sexp
      evals_or_file do |contents, filename|
        sexp = Opal::Parser.new.parse(contents, filename)
        puts sexp.inspect
      end
    end

    def map
      compiler = Compiler.new(file.read, options.merge(:file => file.path))
      compiler.compile
      print compiler.source_map
    end

    def compiler_option_names
      %w[
        method_missing
        arity_check
        dynamic_require_severity
        source_map_enabled
        irb_enabled
        inline_operators
      ]
    end

    # Internal: Yelds a string of source code and the proper filename for either
    #           evals, stdin or a filepath.
    def evals_or_file
      if evals.any?
        yield evals.join("\n"), '-e'
      else
        if file and (filename != '-' or evals.empty?)
          yield file.read, filename
        end
      end
    end

    def puts(*args)
      output.puts(*args)
    end

  end
end
