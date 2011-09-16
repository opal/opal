module Opal

  class Command

    # Valid command line arguments
    COMMANDS = [:help, :irb, :compile, :bundle, :exec, :eval]

    def initialize(args)
      command = args.shift

      if command and COMMANDS.include?(command.to_sym)
        __send__ command.to_sym, *args
      elsif command and File.exists? command
        eval command
      else
        help
      end
    end

    def help
      puts "need to print help"
    end

    # desc "irb", "Opens interactive opal/ruby repl"
    def irb
      ctx = Opal::Context.new
      ctx.start_repl
    end

    def eval(path = nil)
      return "no path given for eval" unless path

      abort "path does not exist `#{path}'" unless File.exist? path

      ctx = Opal::Context.new
      ctx.require_file File.expand_path(path)
    end

    def compile(path)
      puts Opal::Parser.new(File.read(path)).parse!.generate_top
    end

    # desc "bundle", "Bundle the gem in the given directory ready for browser"
    # method_options :out => :string
    def bundle
      opts = options
      bundle = Opal::Bundle.new(Opal::Gem.new(Dir.getwd))
      bundle.build opts
    end
  end
end

