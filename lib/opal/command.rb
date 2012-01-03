require 'optparse'
require 'fileutils'
require 'opal/builder'
require 'opal/version'
require 'opal/compiler'

module Opal
  # Command runner. When using the `opal` bin file, this class is used to
  # delegate commands based on the options passed from the command line.
  class Command

    # Valid command line arguments
    COMMANDS = [:help, :irb, :compile, :eval, :sexp]

    def initialize(args)
      options = {}
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

        opts.on('-b', '--bundle a,b,c', Array, 'Bundle given dependencies') do |r|
          options[:require] = r
        end

        opts.on_tail("-v", "--version", "Show version") do
          puts Opal::VERSION
          exit
        end
      end.parse!

      puts options.inspect
      puts ARGV.inspect
      return

      if options[:compile]
        Compiler.new(ARGV, options).compile
      else
        if ARGV.empty?
          Context.new.start_repl
        elsif File.exists? ARGV.first
          Context.runner ARGV.first
        else
          puts "#{ARGV.first} does not exist"
        end
      end
    end

    def compile(path = nil, *)
      abort "Usage: opal compile [Ruby code or file path]" unless path

      res = if File.exists? path
        Parser.new.parse File.read(path), path
      else
        Parser.new.parse path
      end

      puts res
    end

    def sexp source
      puts Opal::Grammar.new.parse(source).inspect
    end
  end # Command
end

