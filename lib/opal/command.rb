require 'optparse'
require 'fileutils'
require 'opal/bundle'
require 'opal/builder'
require 'opal/version'

module Opal
  # Command runner. When using the `opal` bin file, this class is used to
  # delegate commands based on the options passed from the command line.
  class Command

    # Valid command line arguments
    COMMANDS = [:help, :irb, :compile, :bundle, :build, :exec, :eval,
                :ls, :install, :init]

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

    help_for :init, <<-HELP
Initializes a new project.

Usage:
  opal init [directory]

Directory is optional as project will be generated in current directory
if ommitted.
    HELP
    def init directory = nil
      directory ||= Dir.getwd
      path = File.expand_path(directory)
      base = File.basename(path)
      template = File.join(OPAL_DIR, "templates", "init")

      Dir.chdir(template) do
        Dir["**/*"].each do |f|
          next if File.directory? f

          full = File.expand_path f, template
          dest = File.join path, f.sub(/__NAME__/, base)

          if File.exists? dest
            puts "Skipping #{f}"
            next
          end

          FileUtils.mkdir_p File.dirname(dest)

          File.open(dest, 'w+') do |o|
            o.write File.read(full).gsub(/__NAME__/, base)
          end
        end
      end

      FileUtils.mkdir_p File.join(path, "js")

      %w[opal.js opal-parser.js].each do |src|
        File.open(File.join(path, "js", src), "w+") do |o|
          o.write File.read(File.join(OPAL_DIR, src))
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
      ctx = Context.new :method_missing      => true,
                        :overload_arithmetic => true,
                        :overload_comparison => true,
                        :overload_bitwise    => true
      ctx.start_repl
    end

    help_for :eval, <<-HELP
Evaluate a ruby file or given string

Usage:
  opal eval path/to/file.rb
  opal eval "some ruby string"

If the given arg exists as a file, then the source code is compiled
and then run through a javascript context and the result printed out.

If the arg isn't a file, then it is assumed to be raw ruby code and it
is compiled and run directly with the result being printed out.
HELP
    def eval(code = nil)
      abort "Usage: opal eval [Ruby code or file path]" unless code

      context = Context.new :method_missing      => false,
                            :overload_arithmetic => true,
                            :overload_comparison => true,
                            :overload_bitwise    => true

      if File.exists? code
        context.eval File.read(code), code
      else
        puts context.eval code, "(eval)"
      end

      context.finish
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

      puts res[:code]
    end

    help_for :install, <<-HELP
Install all dependencies from Opalfile

Usage:
  opal install
HELP
    def install(*)
      begin
        Opal::Bundle.new.install
      rescue Opal::OpalfileDoesNotExistError
        abort "No Opalfile found in directory"
      end
    end

    help_for :build, <<-HELP
Build the bundle detailed in Opalfile

Usage:
  opal build [config]

Optional config argument. Defaults to :normal mode
HELP
    def build(*a)
      begin
        builder = Opal::Builder.new
        builder.build *a
      rescue OpalfileDoesNotExistError
        abort "No Opalfile found in directory"
      rescue DependencyNotInstalledError => e
        puts "catching"
        abort "Dependency `#{e}' not installed. Run `opal install' first."
      end
    end

    help_for :ls, <<-HELP
List all dependencies found in Opalfile
HELP
    def ls(*)
      begin
        bundle = Opal::Bundle.load Dir.getwd

        # puts bundle.configs.inspect
        bundle.configs.each do |config, opts|
          puts "#{config}:"
          # puts opts
          opts.each { |k, v| puts "    #{k}: #{v.inspect}" }
          puts
        end
      rescue Opal::OpalfileDoesNotExistError
        abort "No Opalfile found in directory"
      end
    end
  end
end

