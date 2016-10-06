require 'opal'
require 'rack'
require 'opal/builder'
require 'opal/cli_runners'

module Opal
  class CLI
    attr_reader :options, :file, :compiler_options, :evals, :load_paths, :argv,
                :output, :requires, :gems, :stubs, :verbose, :port, :preload,
                :filename, :debug, :no_exit, :lib_only

    class << self
      attr_accessor :stdout
    end

    def initialize options = nil
      options ||= {}

      # Runner
      @runner_type = options.delete(:runner)     || :nodejs
      @port        = options.delete(:port)       || 3000

      @options     = options
      @compile     = !!options.delete(:compile)
      @sexp        = options.delete(:sexp)
      @file        = options.delete(:file)
      @map         = options.delete(:map)
      @no_exit     = options.delete(:no_exit)
      @lib_only    = options.delete(:lib_only)
      @argv        = options.delete(:argv)       || []
      @evals       = options.delete(:evals)      || []
      @load_paths  = options.delete(:load_paths) || []
      @gems        = options.delete(:gems)       || []
      @stubs       = options.delete(:stubs)      || []
      @preload     = options.delete(:preload)    || []
      @output      = options.delete(:output)     || self.class.stdout || $stdout
      @verbose     = options.fetch(:verbose, false); options.delete(:verbose)
      @debug       = options.fetch(:debug, false);   options.delete(:debug)
      @filename    = options.fetch(:filename) { @file && @file.path }; options.delete(:filename)

      @requires    = options.delete(:requires)   || []
      @requires.unshift('opal') unless options.delete(:skip_opal_require)

      @compiler_options = Hash[
        *compiler_option_names.map do |option|
          key = option.to_sym
          next unless options.has_key? key
          value = options.delete(key)
          [key, value]
        end.compact.flatten
      ]

      raise ArgumentError, "no libraries to compile" if @lib_only and @requires.length == 0
      raise ArgumentError, "no runnable code provided (evals or file)" if @evals.empty? and @file.nil? and not(@lib_only)
      raise ArgumentError, "can't accept evals or file in `library only` mode" if (@evals.any? or @file) and @lib_only
      raise ArgumentError, "unknown options: #{options.inspect}" unless @options.empty?
    end

    def run
      return show_sexp if @sexp

      compiled_source = builder.to_s

      File.write @map, builder.source_map if @map

      return puts compiled_source if @compile

      runner.run(compiled_source, argv)
      @exit_status = runner.exit_status
    end

    def runner
      @runner ||= begin
        const_name = @runner_type.to_s.capitalize
        CliRunners.const_defined?(const_name) or
          raise ArgumentError, "unknown runner: #{@runner_type.inspect}"
        CliRunners.const_get(const_name).new(output: output, port: port)
      end
    end

    attr_reader :exit_status

    def builder
      @builder ||= create_builder
    end

    def create_builder
      builder = Opal::Builder.new stubs: stubs, compiler_options: compiler_options

      # --include
      builder.append_paths(*load_paths)

      # --gem
      gems.each { |gem_name| builder.use_gem gem_name }

      # --require
      requires.each { |required| builder.build(required) }

      # --preload
      preload.each { |path| builder.build_require(path) }

      # --verbose
      builder.build_str '$VERBOSE = true', '(flags)' if verbose

      # --debug
      builder.build_str '$DEBUG = true', '(flags)' if debug

      # --eval / stdin / file
      evals_or_file { |source, filename| builder.build_str(source, filename) }

      # --no-exit
      builder.build_str 'Kernel.exit', '(exit)' unless no_exit

      builder
    end

    def show_sexp
      evals_or_file do |contents, filename|
        buffer = ::Parser::Source::Buffer.new(filename)
        buffer.source = contents
        sexp = Opal::Parser.default_parser.parse(buffer)
        puts sexp.inspect
      end
    end

    def compiler_option_names
      %w[
        method_missing
        arity_check
        dynamic_require_severity
        source_map_enabled
        irb_enabled
        inline_operators
        enable_source_location
        parse_comments
      ]
    end

    # Internal: Yields a string of source code and the proper filename for either
    #           evals, stdin or a filepath.
    def evals_or_file
      # --library
      return if lib_only

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
