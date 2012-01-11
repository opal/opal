require 'optparse'
require 'fileutils'
require 'opal/builder'
require 'opal/version'

module Opal
  class Command

    def initialize(args)
      options = {}
      if ARGV.first == 'dependencies'
        options[:dependencies] = true
        ARGV.shift
      elsif ARGV.first == 'build'
        options[:build] = true
        ARGV.shift
      end

      OptionParser.new do |opts|
        opts.on('-c', '--compile', 'Compile ruby') do |c|
          options[:build] = true
        end

        opts.on('-o', '--out FILE', 'Output file') do |o|
          options[:out] = o
        end

        opts.on('-d', '--debug', 'Debug mode') do |d|
          options[:debug] = true
        end

        opts.on_tail("-v", "--version", "Show version") do
          puts Opal::VERSION
          exit
        end
      end.parse!

      if options[:dependencies]
        dependencies options
      elsif options[:build]
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
        abort "#{ARGV.first} does not exist"
      end
    end

    def build(options)
      sources = ARGV.empty? ? ['lib'] : ARGV.dup
      Builder.new(sources, options).build
    end

    def dependencies(options)
      # dont accidentally add fake dependency inside DependencyBuilder
      options.delete :dependencies
      puts "need to build dependnecies #{options.inspect}"
      DependencyBuilder.new(opal: false).build
    end
  end # Command
end
