module Opal
  class Command < Thor

    desc "irb", "Opens interactive opal/ruby repl"
    def irb
      require 'opal/context'
      ctx = Opal::Context.new
      ctx.start_repl
    end

    desc "spec [FILENAME]", "ospec runner"
    long_desc %[
      This will run the ospec gem in the current working directory
      to load the given specs. If no input files are given then
      ospec will run all specs it can find in the spec/ dir.
    ]
    def spec(*specs)
      require 'opal/context'

      argv = specs

      ctx = Opal::Context.new
      ctx.argv = argv
      ctx.require_file 'ospec/autorun'
    end

    desc "compile [FILE]", "Compile and puts compiled code to stdout"
    long_desc %[
      Basically compile the given file, and output it to the
      stdout. This is useful for testing the compiler to see
      what the generated code will be. If the str name is a
      file that exists, it will be read, otherwise the
      content will be run as a string.
    ]
    # TODO make it compile as a string if file not exist
    def compile(str)
      raise "File does not exist: #{str}" unless File.exist? str
      str = "\n\n#{File.read str}"
      code = Opal::RubyParser.new(str).parse!.generate_top
      puts code
    end

    desc "exec [FILENAME]", "Run the given ruby file"
    def exec(file)
      puts "need to run #{file.inspect}"
      require 'opal/context'
      ctx = Opal::Context.new
      ctx.require_file file
    end

    def method_missing(task, *)
      if File.exist? task.to_s
        exec task.to_s
      else
        super
      end
    end
  end
end

