module Opal
  class Context

    def initialize(root_dir = Dir.getwd)
      @root_dir = root_dir
      @builder = Opal::Builder.new

      @load_paths = resolve_load_paths
    end

    # Looks through vendor/ directory and adds all relevant load paths
    def resolve_load_paths
      Dir['vendor/*/package.yml'].map do |package|
        File.expand_path File.join(File.dirname(package), 'lib')
      end
    end

    # Setup the context. This basically loads opal.js into our context, and
    # replace the loader etc with our custom loader for a Ruby environment. The
    # default "browser" loader cannot access files from disk.
    def setup_v8
      return if @v8

      begin
        require 'v8'
      rescue LoadError => e
        abort "therubyracer is required for running javascript. Install it with `gem install therubyracer`"
      end

      @v8 = V8::Context.new
      @v8['console'] = Console.new

      eval @builder.build_core, '(opal)'
      opal = @v8['opal']
      opal['fs'] = FileSystem.new self

      # FIXME: we cant use a ruby array as a js array :(
      opal['loader'] = Loader.new self, eval("[]")

      @load_paths.each do |path|
        eval "opal.loader.paths.push('#{path}')"
      end

    end

    def eval(code, file = nil)
      @v8.eval code, file
    end

    # Require the given id as if it was required in the context. This simply
    # passes the require through to the underlying context.
    def require_file(path)
      setup_v8
      eval "opal.run(function() {opal.require('#{path}');});", path
      finish
    end

    # Set ARGV for the context
    def argv=(args)
      puts "setting argv to #{args.inspect}"
      eval "opal.runtime.cs(opal.runtime.Object, 'ARGV', #{args.inspect});"
    end

    # Start normal js repl
    def start_repl
      require 'readline'
      setup_v8

      loop do
        # on SIGINT lets just return from the loop..
        trap("SIGINT") { finish; return }
        line = Readline.readline '>> ', true

        # if we type exit, then we need to close down context
        if line == "exit"
          break
        end

        puts "=> #{eval_ruby line, '(opal)'}"
      end

      finish
    end

    def eval_ruby(content, line = "")
      begin
        code = Opal::Parser.new(content).parse!.generate_top
        code = "opal.run(function() {var $rb = opal.runtime, self = $rb.top, __FILE__ = '(opal)';" + code + "});"
        # puts code
        @v8['$opal_irb_result'] = eval code, line
        eval "!($opal_irb_result == null || !$opal_irb_result.m$inspect) ? $opal_irb_result.m$inspect() : '(Object does not support #inspect)'"
      rescue => e
        puts e
        puts("\t" + e.backtrace.join("\n\t"))
      end
    end

    # Finishes the context, i.e. tidy everything up. This will cause
    # the opal runtime to do it's at_exit() calls (if applicable) and
    # then the v8 context will de removed. It can be reset by calling
    # #setup_v8
    def finish
      return unless @v8
      eval "opal.runtime.do_at_exit()", "(opal)"

      @v8 = nil
    end

    # Console class is used to mimic the console object in web browsers
    # to allow simple debugging to the stdout.
    class Console
      def log(*str)
        puts str.join("\n")
        nil
      end
    end

    # FileSystem is used to interact with the file system from the ruby
    # version of opal. The methods on this class replace the default ones
    # made available in the web browser.
    class FileSystem

      def initialize(context)
        @context = context
      end

      def cwd
        Dir.getwd
      end

      def glob(*arr)
        Dir.glob arr
      end

      def exist_p(path)
        File.exist? path
      end

      def expand_path(filename, dir_string = nil)
        File.expand_path filename, dir_string
      end

      def dirname(file)
        File.dirname file
      end

      def join(*parts)
        File.join *parts
      end
    end

    # Loader for v8 context
    class Loader

      attr_reader :paths

      def initialize(context, paths)
        @context = context
        @paths = paths
      end

      def resolve_lib(id)
        resolved = find_lib id
        raise "Cannot find lib `#{id}'" unless resolved

        resolved
      end

      def find_lib(id)
        @paths.each do |path|
          candidate = File.join path, "#{id}.rb"
          return candidate if File.exists? candidate

          candidate = File.join path, id
          return candidate if File.exists? candidate
        end

        return File.expand_path id if File.exists? id
        return File.expand_path(id + '.rb') if File.exists?(id + '.rb')

        nil
      end

      def ruby_file_contents(filename)
        Opal::Parser.new(File.read(filename)).parse!.generate_top
      end

      def wrap(content, filename)
        code = "(function($rb, self, __FILE__) { #{content} });"
        @context.eval code, filename
        # code
      end
    end

  end
end

