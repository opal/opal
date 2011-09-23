module Opal
  # Command runner. When using the `opal` bin file, this class is used to
  # delegate commands based on the options passed from the command line.
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

    # Starts an irb session using an inline v8 context. Commands can be
    # entered just like IRB. Use Ctrl-C or type `exit` to quit.
    def irb(*)
      ctx = Context.new :method_missing      => true,
                        :overload_arithmetic => true,
                        :overload_comparison => true,
                        :overload_bitwise    => true
      ctx.start_repl
    end

    # If the given arg exists as a file, then the source code is compiled
    # and then run through a javascript context and the result printed out.
    #
    # If the arg isn't a file, then it is assumed to be raw ruby code and it
    # is compiled and run directly with the result being printed out.
    #
    # Usage:
    #
    #   opal eval path/to/some/file.rb
    #   # => "some result"
    #
    #   opal eval "1.class"
    #   # => Numeric
    #
    # @param [String] code path or ruby code to eval
    def eval(code = nil, *)
      abort "Usage: opal eval [Ruby code or file path]" unless code

      if File.exists? code
        code = Parser.new.parse File.read(code)
      end

      context = Context.new :method_missing      => true,
                            :overload_arithmetic => true,
                            :overload_comparison => true,
                            :overload_bitwise    => true

      puts context.eval code
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
    def compile(path = nil, *)
      abort "Usage: opal compile [Ruby code or file path]" unless path

      if File.exists? path
        puts Parser.new.parse File.read(path)
      else
        puts Parser.new.parse path
      end
    end

    # Bundle the gem (browserify) ready for the browser
    def bundle(*)
      # lazy load incase user does not have rbp installed
      require 'opal/bundle'

      path    = File.join Dir.getwd, 'package.yml'
      package = Rbp::Package.load_path path
      bundle  = Bundle.new package

      puts bundle.build
    end
  end
end

