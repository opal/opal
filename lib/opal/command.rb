require 'optparse'
require 'fileutils'
require 'opal/builder'
require 'opal/version'

module Opal
  class Command

    def initialize(args)
      options = {}
      if ARGV.first == 'init'
        options[:init] = true
        ARGV.shift
      end

      OptionParser.new do |opts|
        opts.on('-c', '--compile', 'Compile ruby') do |c|
          options[:compile] = c
        end

        opts.on('-o', '--output [DIR]', 'Output directory') do |o|
          options[:output] = o || ''
        end

        opts.on('-j', '--join [OUT]', 'Join output') do |j|
          options[:join] = j || ''
        end

        opts.on('-d', '--debug', 'Debug mode') do |d|
          options[:debug] = true
        end

        opts.on_tail("-v", "--version", "Show version") do
          puts Opal::VERSION
          exit
        end
      end.parse!

      if options[:init]
        init options
      elsif options[:compile]
        build options
      else
        run options
      end
    end

    def run(options)
      if ARGV.empty?
        Context.new.start_repl
      elsif File.exists? ARGV.first
        Context.runner ARGV.first
      else
        puts "#{ARGV.first} does not exist"
      end
    end

    def init(options)
      out   = options[:output]
      src   = options[:debug] ? Opal.runtime_debug_code : Opal.runtime_code
      out ||= (options[:debug] ? 'opal.debug.js' : 'opal.js')

      File.open(out, 'w+') { |o| o.write src }
      puts "Wrote Opal to #{out}#{options[:debug] && ' (debug)'}"
    end

    def build(options)
      Builder.new(ARGV, options).build
    end
  end # Command
end
