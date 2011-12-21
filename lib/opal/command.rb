require 'optparse'
require 'fileutils'
require 'opal/builder'
require 'opal/version'

module Opal
  # Command runner. When using the `opal` bin file, this class is used to
  # delegate commands based on the options passed from the command line.
  class Command

    # Valid command line arguments
    COMMANDS = [:help, :irb, :compile, :eval, :sexp]

    def initialize(args)
      command = args.shift

      if ['version', '-v', '--version'].include? command
        return puts Opal::VERSION
      end

      if command and COMMANDS.include?(command.to_sym)
        __send__ command.to_sym, *args
      elsif command and File.exists? command
        eval command
      else
        help
      end
    end


    # Help
    class << self
      def help
        @help ||= {}
      end

      def help_for method, description
        help[method.to_sym] = description
      end
    end

    help_for :help, <<-HELP
Print the help message

@param [String] command name
    HELP
    def help command = nil
      if command
        puts self.class.help[command.to_sym]
      else
        puts 'Commands:'
        self.class.help.each_pair do |cmd, desc|
          puts "  opal #{cmd.to_s.ljust(10)}# #{desc[0..desc.index("\n")].lstrip}"
        end
      end
    end

    help_for :irb, <<-HELP
Starts opal REPL

Usage:
    opal irb

Starts an irb session using an inline v8 context. Commands can be
entered just like IRB. Use Ctrl-C or type `exit` to quit.
HELP
    def irb(*)
      ctx = Context.new
      ctx.start_repl
    end

    help_for :eval, <<-HELP
Evaluate a ruby file

Usage:
  opal eval path/to/file.rb
HELP
    def eval(file = nil)
      abort "Usage: opal eval [path]" unless File.exists? file
      Context.runner(file)
    end

    help_for :compile, <<-HELP
Compile a ruby file or given string

Usage:
  opal compile path/to/file.rb
  opal compile "some ruby string"

If the given path exists, then compiles the source code of that
file and spits out the generated javascript.

If this file does not exist, then assumes the input is ruby code
to compile and return.
HELP
    def compile(path = nil, *)
      abort "Usage: opal compile [Ruby code or file path]" unless path

      res = if File.exists? path
        Parser.new.parse File.read(path)
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

