# frozen_string_literal: true

require 'opal/requires'
require 'opal/builder'
require 'opal/cli_runners'
require 'stringio'

module Opal
  class CLI
    attr_reader :options, :file, :compiler_options, :evals, :load_paths, :argv,
      :output, :requires, :rbrequires, :gems, :stubs, :verbose, :runner_options,
      :preload, :debug, :no_exit, :lib_only, :missing_require_severity,
      :filename, :stdin, :no_cache

    class << self
      attr_accessor :stdout
    end

    class Evals < StringIO
      def to_path
        '-e'
      end
    end

    def initialize(options = nil)
      options ||= {}

      # Runner
      @runner_type    = options.delete(:runner)         || :nodejs
      @runner_options = options.delete(:runner_options) || {}

      @options     = options
      @sexp        = options.delete(:sexp)
      @repl        = options.delete(:repl)
      @no_exit     = options.delete(:no_exit)
      @lib_only    = options.delete(:lib_only)
      @argv        = options.delete(:argv)       { [] }
      @evals       = options.delete(:evals)      { [] }
      @load_paths  = options.delete(:load_paths) { [] }
      @gems        = options.delete(:gems)       { [] }
      @stubs       = options.delete(:stubs)      { [] }
      @preload     = options.delete(:preload)    { [] }
      @output      = options.delete(:output)     { self.class.stdout || $stdout }
      @verbose     = options.delete(:verbose)    { false }
      @debug       = options.delete(:debug)      { false }
      @requires    = options.delete(:requires)   { [] }
      @rbrequires  = options.delete(:rbrequires) { [] }
      @no_cache    = options.delete(:no_cache)   { false }
      @stdin       = options.delete(:stdin)      { $stdin }
      @dce         = options.delete(:dce)        { false }

      @debug_source_map = options.delete(:debug_source_map) { false }

      @missing_require_severity = options.delete(:missing_require_severity) { Opal::Config.missing_require_severity }

      @requires.unshift('opal') unless options.delete(:skip_opal_require)

      @compiler_options = compiler_option_names.map do |option|
        key = option.to_sym
        next unless options.key? key
        value = options.delete(key)
        [key, value]
      end.compact.to_h

      if @lib_only
        raise ArgumentError, 'no libraries to compile' if @requires.empty?
        raise ArgumentError, "can't accept evals, file, or extra arguments in `library only` mode" if @argv.any? || @evals.any?
      elsif @evals.any?
        @filename = '-e'
        @file = Evals.new(@evals.join("\n"))
      elsif @argv.first && @argv.first != '-'
        @filename = @argv.shift
        @file = File.open(@filename)
      else
        @filename = @argv.shift || '-'
        @file = @stdin
      end

      raise ArgumentError, "unknown options: #{options.inspect}" unless @options.empty?
    end

    def run
      return show_sexp if @sexp
      return debug_source_map if @debug_source_map
      return run_repl if @repl

      rbrequires.each { |file| require file }

      runner = self.runner

      # Some runners may need to use a dynamic builder, that is,
      # a builder that will try to build the entire package every time
      # a page is loaded - for example a Server runner that needs to
      # rerun if files are changed.
      builder = proc { create_builder }

      @exit_status = runner.call(
        options: runner_options,
        output: output,
        argv: argv,
        builder: builder,
      )
    end

    def runner
      CliRunners[@runner_type] ||
        raise(ArgumentError, "unknown runner: #{@runner_type.inspect}")
    end

    def run_repl
      require 'opal/repl'

      repl = REPL.new
      repl.run(argv)
    end

    attr_reader :exit_status

    def create_builder
      builder = Opal::Builder.new(
        stubs: stubs,
        compiler_options: compiler_options,
        missing_require_severity: missing_require_severity,
      )

      builder.dce = @dce

      # --no-cache
      builder.cache = Opal::Cache::NullCache.new if no_cache

      # --include
      builder.append_paths(*load_paths)

      # --gem
      gems.each { |gem_name| builder.use_gem gem_name }

      # --require
      requires.each { |required| builder.build(required, requirable: true, load: true) }

      # --preload
      preload.each { |path| builder.build_require(path) }

      # --verbose
      builder.build_str '$VERBOSE = true', '(flags)', no_export: true if verbose

      # --debug
      builder.build_str '$DEBUG = true', '(flags)', no_export: true if debug

      # --eval / stdin / file
      source = evals_or_file_source
      builder.build_str(source, filename) if source

      # --no-exit
      builder.build_str '::Kernel.exit', '(exit)', no_export: true unless no_exit

      builder
    end

    def show_sexp
      source = evals_or_file_source or return # rubocop:disable Style/AndOr

      buffer = ::Opal::Parser::SourceBuffer.new(filename)
      buffer.source = source
      sexp = Opal::Parser.default_parser.parse(buffer)
      output.puts sexp.inspect
    end

    def debug_source_map
      source = evals_or_file_source or return # rubocop:disable Style/AndOr

      compiler = Opal::Compiler.new(source, file: filename, **compiler_options)

      compiler.compile

      b64 = [
        compiler.result,
        compiler.source_map.to_json,
        evals_or_file_source,
      ].map { |i| Base64.strict_encode64(i) }.join(',')

      output.puts "https://sokra.github.io/source-map-visualization/#base64,#{b64}"
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
        enable_file_source_embed
        use_strict
        parse_comments
        esm
      ]
    end

    # Internal: Yields a string of source code and the proper filename for either
    #           evals, stdin or a filepath.
    def evals_or_file_source
      return if lib_only # --library
      return @cached_content if @cached_content

      unless file.tty?
        begin
          file.rewind
          can_read_again = true
        rescue Errno::ESPIPE # rubocop:disable Lint/HandleExceptions
          # noop
        end
      end

      if @cached_content.nil? || can_read_again
        # On MacOS file.read is not enough to pick up changes, probably due to some
        # cache or buffer, unclear if coming from ruby or the OS.
        content = File.file?(file) ? File.read(file) : file.read
      end

      @cached_content ||= content unless can_read_again
      content
    end
  end
end
