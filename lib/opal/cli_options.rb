require 'optparse'

module Opal
  class CLIOptions < OptionParser
    def initialize
      @options = {}

      super do |opts|
        opts.banner = 'Usage: opal [options] -- [programfile]'

        opts.on('-v', '--verbose', 'print version number, then turn on verbose mode') do |v|
          print_version
          options[:verbose] = true # TODO: print some warnings when verbose = true
        end

        opts.on('--verbose', 'turn on verbose mode') do
          options[:verbose] = true # TODO: print some warnings when verbose = true
        end

        opts.on('--version', 'Print the version') do |v|
          print_version
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

        opts.on('--server [PORT]', 'Start a server (default port: 3000)') do |port|
          options[:server] = true
          options[:port] = port.to_i
        end

        opts.on('-g', '--gem GEM_NAME', String,
                'Adds the specified GEM_NAME to Opal\'s load path.',
                'E.g.: opal --require opal-browser browser`',
                'Will build browser.rb from the Opal gem opal-browser') do |g|
          options[:gems] ||= []
          options[:gems] << g
        end

        opts.on('-s', '--stub STUB', String) do |stub|
          options[:stubs] ||= []
          options[:stubs] << stub
        end


        opts.separator ''
        opts.separator 'Compilation Options:'

        opts.on('-M', '--[no-]method-missing', 'Enable/Disable method missing') do |val|
          options[:method_missing] = val
        end

        opts.on('-O', '--[no-]opal', 'Enable/Disable implicit `require "opal"`') do |value|
          options[:skip_opal_require] = !value
        end

        opts.on('-A', '--[no-]arity-check', 'Enable/Disable arity check') do |value|
          options[:arity_check] = value
        end

        opts.on('-C', '--[no-]const-missing', 'Enable/Disable const missing') do |value|
          options[:const_missing] = value
        end

        dynamic_require_levels = %w[error warning ignore]
        opts.on('-D', '--dynamic-require LEVEL', dynamic_require_levels,
                      'Set level of dynamic require severity') do |level|
          options[:dynamic_require_severity] = level.to_sym
        end

        opts.on('-P', '--[no-]source-map', 'Enable/Disable source map') do |value|
          options[:source_map_enabled] = value
        end

        opts.on('-F', '--file FILE', 'Set filename for compiled code') do |file|
          options[:file] = file
        end

        opts.on("--[no-]irb", "Enable/Disable IRB var mode") do |flag|
          options[:irb] = flag
        end
      end
    end

    def print_version
      require 'opal/version'
      puts "Opal v#{Opal::VERSION}"
    end

    attr_reader :options
  end
end
