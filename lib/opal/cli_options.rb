# frozen_string_literal: true

require 'optparse'
require 'opal/cli_runners'

module Opal
  class CLIOptions < OptionParser
    def initialize
      super
      @options = {}

      self.banner = 'Usage: opal [options] -- [programfile]'

      separator ''

      on('--repl', 'Run the Opal REPL') do
        options[:repl] = true
      end

      on('-v', '--verbose', 'print version number, then turn on verbose mode') do
        print_version
        exit if ARGV.empty?
        options[:verbose] = true
      end

      on('--verbose', 'turn on verbose mode (set $VERBOSE to true)') do
        options[:verbose] = true
      end

      on('-d', '--debug', 'turn on debug mode (set $DEBUG to true)') do
        options[:debug] = true
      end

      on('--version', 'Print the version') do
        print_version
        exit
      end

      on('-h', '--help', 'Show this message') do
        puts self
        exit
      end

      section 'Basic Options:'

      on('-e', '--eval SOURCE', String,
        'One line of script. Several -e\'s allowed. Omit [programfile]'
      ) do |source|
        options[:evals] ||= []
        options[:evals] << source
      end

      on('-r', '--require LIBRARY', String,
        'Require the library before executing your script'
      ) do |library|
        options[:requires] ||= []
        options[:requires] << library
      end

      on('-q', '--rbrequire LIBRARY', String,
        'Require the library in Ruby context before compiling'
      ) do |library|
        options[:rbrequires] ||= []
        options[:rbrequires] << library
      end

      on('-I', '--include DIR', 'Append a load path (may be used more than once)') do |i|
        options[:load_paths] ||= []
        options[:load_paths] << i
      end

      on('-s', '--stub FILE', String, 'Stubbed files will be compiled as empty files') do |stub|
        options[:stubs] ||= []
        options[:stubs] << stub
      end

      on('-p', '--preload FILE', String, 'Preloaded files will be prepared for dynamic requires') do |stub|
        options[:preload] ||= []
        options[:preload] << stub
      end

      on('-g', '--gem GEM_NAME', String, 'Adds the specified GEM_NAME to Opal\'s load path.') do |g|
        options[:gems] ||= []
        options[:gems] << g
      end

      section 'Running Options:'

      on('-R', '--runner RUNNER', Opal::CliRunners.to_h.keys, 'Choose the runner:', "nodejs (default), #{(Opal::CliRunners.to_h.keys - %i[nodejs compiler]).join(', ')}") do |runner|
        options[:runner] = runner.to_sym
      end

      on('--server-port PORT', 'Set the port for the server runner (default port: 3000)') do |port|
        options[:runner_options] ||= {}
        options[:runner_options][:port] = port.to_i
      end

      on('--runner-options JSON', 'Set options specific to the selected runner as a JSON string (e.g. port for server)') do |json_options|
        require 'json'
        runner_options = JSON.parse(json_options, symbolize_names: true)
        options[:runner_options] ||= {}
        options[:runner_options].merge!(runner_options)
      end

      section 'Builder Options:'

      on('-c', '--compile', 'Compile to JavaScript') do
        options[:runner] = :compiler
      end

      on('-o', '--output FILE', 'Output JavaScript to FILE (or directory if --directory enabled)') do |file|
        options[:output] = file
      end

      on('-P', '--map FILE', 'Output source map to FILE') do |file|
        options[:runner_options] ||= {}
        options[:runner_options][:map_file] = file
      end

      on('--no-source-map', "Don't append source map to a compiled file") do
        options[:runner_options] ||= {}
        options[:runner_options][:no_source_map] = true
      end

      on('--watch', 'Run the compiler in foreground, recompiling every filesystem change') do
        options[:runner_options] ||= {}
        options[:runner_options][:watch] = true
      end

      on('--no-cache', 'Disable filesystem cache') do
        options[:no_cache] = true
      end

      on('-L', '--library', 'Compile only required libraries. Omit [programfile] and [-e]. Assumed [-cOE].') do
        options[:lib_only] = true
        options[:no_exit] = true
        options[:compile] = true
        options[:skip_opal_require] = true
      end

      on('-O', '--no-opal', 'Disable implicit `require "opal"`') do
        options[:skip_opal_require] = true
      end

      on('-E', '--no-exit', 'Do not append a Kernel#exit at the end of file') do
        options[:no_exit] = true
      end

      section 'Compiler Options:'

      on('--use-strict', 'Enables JavaScript\'s strict mode (i.e., adds \'use strict\'; statement)') do
        options[:use_strict] = true
      end

      on('--esm', 'Wraps compiled bundle as for ES6 module') do
        options[:esm] = true
      end

      on('--directory', 'Builds the program as a directory of JS files') do
        options[:directory] = true
      end

      on('-A', '--arity-check', 'Enable arity check') do
        options[:arity_check] = true
      end

      dynamic_require_levels = %w[error warning ignore]
      on('-D', '--dynamic-require LEVEL', dynamic_require_levels,
        'Set level of dynamic require severity.',
        "(default: error, values: #{dynamic_require_levels.join(', ')})"
      ) do |level|
        options[:dynamic_require_severity] = level.to_sym
      end

      missing_require_levels = %w[error warning ignore]
      on('--missing-require LEVEL', missing_require_levels,
        'Set level of missing require severity.',
        "(default: error, values: #{missing_require_levels.join(', ')})"
      ) do |level|
        options[:missing_require_severity] = level.to_sym
      end

      on('--enable-source-location', 'Compiles source location for each method definition.') do
        options[:enable_source_location] = true
      end

      on('--parse-comments', 'Compiles comments for each method definition.') do
        options[:parse_comments] = true
      end

      on('--enable-file-source-embed', 'Embeds file sources to be accessed by applications.') do
        options[:enable_file_source_embed] = true
      end

      on('--irb', 'Enable IRB var mode') do
        options[:irb] = true
      end

      on('-M', '--no-method-missing', 'Disable method missing') do
        options[:method_missing] = false
      end

      on('-F', '--file FILE', 'Set filename for compiled code') do |file|
        options[:file] = file
      end

      on('-V', '(deprecated; always enabled) Enable inline Operators') do
        warn '* -V is deprecated and has no effect'
        options[:inline_operators] = true
      end

      section 'Debug Options:'

      on('--sexp', 'Show Sexps') do
        options[:sexp] = true
      end

      on('--debug-source-map', 'Debug source map') do
        options[:debug_source_map] = true
      end

      separator ''
    end

    attr_reader :options


    private

    def print_version
      require 'opal/version'
      puts "Opal v#{Opal::VERSION}"
    end

    def section(title)
      separator ''
      separator title
      separator ''
    end
  end
end
