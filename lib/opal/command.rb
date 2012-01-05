require 'optparse'
require 'fileutils'
require 'opal/builder'
require 'opal/version'

module Opal
  class Command

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

        opts.on_tail("-v", "--version", "Show version") do
          puts Opal::VERSION
          exit
        end
      end.parse!

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
  end # Command
end
