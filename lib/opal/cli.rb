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
      @options = options
      @filename = filename
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
      full_source = sprockets[filename]
      IO.popen('node', 'w') do |stdin|
        stdin.write full_source
      end
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
        (options[:load_paths] || []).each do |path|
          s.append_path path
        end
        s.main = File.basename(filename, '.rb')
      end
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
