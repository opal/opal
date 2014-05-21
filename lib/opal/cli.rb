require 'opal'
require 'rack'
require 'opal/builder'
require 'opal/cli_runners/nodejs'
require 'opal/cli_runners/server'

module Opal
  class CLI
    attr_reader :options, :file, :compiler_options, :evals, :load_paths,
                :output, :requires, :gems, :stubs, :verbose, :port

    def compile?
      @compile
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
      @file       = options.delete(:file)
      @evals      = options.delete(:evals)      || []
      @requires   = options.delete(:requires)   || []
      @load_paths = options.delete(:load_paths) || []
      @gems       = options.delete(:gems)       || []
      @stubs      = options.delete(:stubs)      || []
      @output     = options.delete(:output)     || self.class.stdout || $stdout
      @verbose    = options.fetch(:verbose, false); options.delete(:verbose)
      @skip_opal_require = options.delete(:skip_opal_require)
      @compiler_options = Hash[
        *processor_option_names.map do |option|
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
      when options[:sexp]; show_sexp
      when compile?;       show_compiled_source
      else                 run_code
      end
    end

    def runner
      @runner ||= case @runner_type
                  when :server; CliRunners::Server.new(output, port)
                  when :nodejs; CliRunners::Nodejs.new(output)
                  else raise ArgumentError, @runner_type.inspect
                  end
    end

    def run_code
      full_source = compiled_source
      runner.run(full_source)
    end

    def compiled_source
      Opal.paths.concat load_paths
      gems.each { |gem_name| Opal.use_gem gem_name }

      builder = Opal::Builder.new :stubbed_files => stubs, :compiler_options => compiler_options

      # REQUIRES: -r
      requires.unshift 'opal' unless skip_opal_require?
      requires.each do |local_require|
        builder.build_str("require #{local_require.inspect}", 'require')
      end

      # EVALS: -e
      evals.each do |eval|
        builder.build_str(eval, '-e')
      end

      # FILE: ARGF
      if file and (file.path != '-' or evals.empty?)
        builder.build_str(file.read, file.path)
      end

      builder.to_s
    end

    def show_compiled_source
      puts compiled_source
    end

    def show_sexp
      puts sexp.inspect
    end

    def map
      compiler = Opal::Compiler.compile(file.read, options.merge(:file => file.path))
      compiler.compile
      compiler.source_map
    end

    def sexp
      Opal::Parser.new.parse(source)
    end

    def source
      file.read
    end

    def processor_option_names
      %w[
        method_missing_enabled
        arity_check_enabled
        const_missing_enabled
        dynamic_require_severity
        source_map_enabled
        irb_enabled
      ]
    end

    def puts(*args)
      output.puts(*args)
    end

  end
end
