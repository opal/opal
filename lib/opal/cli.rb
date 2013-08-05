begin
  require 'opal-sprockets'
rescue LoadError
  $stderr.puts 'Opal executable requires opal-sprockets to be fully functional.'
  $stderr.puts 'You can install it with rubygems:'
  $stderr.puts ''
  $stderr.puts '    gem install opal-sprockets'
  exit -1
end

require 'opal'
require 'rack'

module Opal
  class CLI
    attr_reader :options, :filename

    def initialize filename, options
      @options = options || {}
      @filename = filename
    end

    def puts *args
      output.puts *args
    end

    def output
      @output ||= options[:output] || $stdout
    end


    def run
      set_processor_options
      prepare_eval_code

      case
      when options[:sexp];    show_sexp
      when options[:compile]; show_compiled_source
      when options[:server];  start_server
      else                    run_code
      end
    end

    def show_compiled_source
      if sprockets[filename]
        puts sprockets[filename].to_a.last
      else
        puts Opal.parse(filename, options)
      end
    end

    def show_sexp
      puts sexp.inspect
    end

    def set_processor_options
      processor_options.each do |option|
        key = option.to_sym
        next unless options.has_key? key
        Opal::Processor.send("#{option}=", options[key])
      end
    end

    def prepare_eval_code
      if options[:evals] and options[:evals].any?
        require 'tmpdir'
        path = File.join(Dir.mktmpdir,"opal-#{$$}.js.rb")
        File.open(path, 'w') do |tempfile|
          options[:load_paths] ||= []
          options[:load_paths] << File.dirname(path)

          options[:evals].each do |code|
            tempfile.puts 'require "opal"'
            tempfile.puts code
          end
        end
        @filename = File.basename(path)
      end
    end

    def run_code
      begin
        full_source = sprockets[filename]
      rescue Sprockets::FileOutsidePaths => e
        @server = nil
        full_path = File.expand_path(filename)
        load_paths << File.dirname(full_path)
        _filename = File.basename(full_path)
        full_source = sprockets[_filename]
      end

      require 'open3'
      out, err, status = Open3.capture3('node', :stdin_data => full_source)
      raise "Errored: #{err}" if status != 0
      puts out

    rescue Errno::ENOENT
      $stderr.puts 'Please install Node.js to be able to run Opal scripts.'
      exit 127
    end

    def sexp
      Opal::Grammar.new.parse(source)
    end

    def map
      parser = Opal::Parser.new
      parser.parse(filename, options)
      parser.source_map
    end

    def source
      File.exist?(filename) ? File.read(filename) : filename
    end

    def processor_options
      %w[
        method_missing_enabled
        optimized_operators_enabled
        arity_check_enabled
        const_missing_enabled
        dynamic_require_severity
        source_map_enabled
        irb_enabled
      ]
    end

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

    def load_paths
      @load_paths ||= options[:load_paths] || []
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
  end
end
