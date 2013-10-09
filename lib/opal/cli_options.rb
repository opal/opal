require 'optparse'

module Opal
  class CLIOptions < OptionParser
    def initialize
      @options = {}

      super do |opts|
        opts.banner = 'Usage: opal [options] -- [programfile]'

        opts.on('-v', '--version', 'Display Opal Version') do |v|
          require 'opal/version'
          puts "Opal v#{Opal::VERSION}"
          exit
        end

        opts.on("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        opts.separator ''
        opts.separator 'Basic Options:'

        opts.on('-I', '--include DIR',
                'Append a load path (may be used more than once)') do |i|
          options[:load_paths] ||= []
          options[:load_paths] << i
        end

        opts.on('-e', '--eval SOURCE', String,
                'One line of script. Several -e\'s allowed. Omit [programfile]') do |source|
          options[:evals] ||= []
          options[:evals] << source
        end

        opts.on('-r', '--require LIBRARY', String,
                'Require the library before executing your script') do |library|
          options[:requires] ||= []
          options[:requires] << library
        end

        opts.on('-s', '--sexp', 'Show Sexps') do
          options[:sexp] = true
        end

        opts.on('-m', '--map', 'Show sourcemap') do
          options[:map] = true
        end

        opts.on('-c', '--compile', 'Compile to JavaScript') do
          options[:compile] = true
        end

        opts.on('-s', '--server [PORT]', 'Start a server (default port: 3000)') do |port|
          options[:server] = port.to_i
        end


        opts.separator ''
        opts.separator 'Compilation Options:'

        opts.on('-M', '--no-method-missing', 'Disable method missing') do |value|
          options[:method_missing] = false
        end

        opts.on('-O', '--no-optimized-operators', 'Disable optimized operators') do |value|
          options[:optimized_operators_enabled] = false
        end

        opts.on('-A', '--arity-check', 'Enable arity check') do |value|
          options[:arity_check] = true
        end

        opts.on('-C', '--no-const-missing', 'Disable const missing') do |value|
          options[:const_missing] = false
        end

        dynamic_require_levels = %w[error warning ignore]
        opts.on('-D', '--dynamic-require LEVEL', dynamic_require_levels,
                      'Set levelDynamic require severity') do |level|
          options[:dynamic_require_severity] = level
        end

        opts.on('-P', '--no-source-map', 'Disable source map') do |value|
          options[:source_map_enabled] = false
        end

        opts.on("--irb", "IRB var mode") do |i|
          options[:irb] = true
        end
      end
    end

    attr_reader :options
  end
end
