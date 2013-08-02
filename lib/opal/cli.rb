require 'opal'

begin
  require 'opal-sprockets'
rescue LoadError
  $stderr.puts 'Opal executable requires opal-sprockets to be fully functional.'
  $stderr.puts 'You can install it with rubygems:'
  $stderr.puts ''
  $stderr.puts '    gem install opal-sprockets'
  exit -1
end

module Opal
  class CLI
    attr_reader :options, :filename

    def initialize _filename, options
      require 'rack'

      @options = options
      @filename = _filename

      processor_options.each do |option|
        key = option.to_sym
        next unless options.has_key? key
        Opal::Processor.send("#{option}=", options[key])
      end

      if options[:evals] and options[:evals].any?
        require 'tempfile'
        path = File.join(Dir.tmpdir,"opal-#{$$}.js.rb")
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

      case
      when options[:sexp]
        puts sexp.inspect
      when options[:map]
        puts map.inspect
      when options[:compile]
        if File.exist?(filename)
          puts sprockets[filename].to_a.last
        else
          puts Opal.parse(filename, options)
        end
      when options[:server]
        server_start
      else
        run
      end
    end

    def run
      begin
        full_source = sprockets[filename]
        IO.popen('node', 'w') do |stdin|
          stdin.write full_source
        end
      rescue Errno::ENOENT
        $stderr.puts 'Please install Node.js to be able to run Opal scripts.'
        exit 127
      end
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

    def server_start
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
