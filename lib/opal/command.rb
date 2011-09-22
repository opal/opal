module Opal

  class Command

    # Valid command line arguments
    COMMANDS = [:help, :irb, :compile, :bundle, :exec, :eval, :install]

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

    # If the given path exists, then compiles the source code of that
    # file and spits out the generated javascript.
    #
    # If this file does not exist, then assumes the input is ruby code
    # to compile and return.
    #
    # Usage:
    #
    #   opal compile path/to/ruby.rb
    #   # => "generated code"
    #
    #   opal compile "some ruby code"
    #   # => generated code
    #
    # @param [String] path file path or ruby code
    def compile(path)
      if File.exists? path
        puts Parser.new.parse File.read(path)
      else
        puts Parser.new.parse path
      end
    end

    def install
      install = RBP::Install.new
      install.install
    end

    # Bundle the gem (browserify) ready for the browser
    def bundle
      # lazy load incase user does not have rbp installed
      require 'opal/bundle'

      path    = File.join Dir.getwd, 'package.yml'
      package = Rbp::Package.load_path path
      bundle  = Bundle.new package

      puts bundle
      puts bundle.package

      puts bundle.build
    end
  end
end

