require 'opal/environment'

module Opal
  class Context

    attr_reader :v8
    attr_reader :parser
    attr_reader :environment

    ##
    # Glob may be a file or glob path, as a string.

    def self.runner(glob, debug = true)
      ctx = self.new debug
      files = Dir[glob]
      ctx.v8['opal_tmp_glob'] = files

      main = File.expand_path files.first unless files.empty?

      runner = <<-CODE
        files = `opal_tmp_glob`
        $0 = '#{main}'

        files.each do |a|
          require a
        end
      CODE

      ctx.eval_irb runner, '(runner)'
      ctx.finish
    end

    def initialize(debug = true)
      @debug        = true
      @environment  = Environment.load Dir.getwd
      @parser       = Opal::Parser.new :debug => debug
      @loaded_paths = false

      setup_v8
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
        if line == "exit" or line.nil?
          break
        end

        puts "=> #{eval_irb line, '(irb)'}"
      end

      finish
    end

    def eval_builder(content, file)
      "(#{@parser.parse content, file}).call(opal.top, opal)"
    end

    def eval(content, file = "(irb)", line = "")
      @v8.eval eval_builder(content, file), file
    end

    def eval_irb(content, file = '(irb)')
      code = <<-CODE
        (function() { try {
          opal.FILE = '#{file}';
          var res = #{ eval_builder content, file };
          return res.$inspect();
         }
         catch (e) {
           console.log(e.o$klass.o$name + ': ' + e.message);
           //console.log("\\t" + e.$backtrace().join("\\n\\t"));
           return "nil";
         }
        })()
      CODE

      @v8.eval code, file
    rescue Opal::OpalParseError => e
      puts "ParseError: #{e.message}"
      "nil"
    rescue V8::JSError => e
      puts "SyntaxError: #{e.message}"
      "nil"
    end

    # Finishes the context, i.e. tidy everything up. This will cause
    # the opal runtime to do it's at_exit() calls (if applicable) and
    # then the v8 context will de removed. It can be reset by calling
    # #setup_v8
    def finish
      return unless @v8
      @v8.eval "opal.do_at_exit()", "(irb)"

      @v8 = nil
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
      @v8['opal_filesystem'] = FileSystem.new(self)

      load_runtime
      load_gem_runtime
    end

    ##
    # Loads the runtime from build/*.js. This isnt included in the git repo,
    # so needs to be built before running (gems should have these files included)

    def load_runtime
      code = @debug ? Opal.runtime_debug_code : Opal.runtime_code
      @v8.eval code, '(runtime)'
    end

    ##
    # Load gem specific runtime.

    def load_gem_runtime
      path = File.join Opal.opal_dir, 'core', 'gemlib.rb'
      eval File.read(path), path
    end

    ##
    # Console class is used to mimic the console object in web browsers
    # to allow simple debugging to the stdout.

    class Console
      def log(*str)
        puts str.join("\n")
        nil
      end
    end

    ##
    # FileSystem is used to interact with the file system from the ruby
    # version of opal. The methods on this class replace the default ones
    # made available in the web browser.

    class FileSystem

      def initialize context
        @context     = context
        @environment = context.environment
        @cache       = {}
      end

      ##
      # Used to bootstrap loadpaths.

      def find_paths
        return @paths if @paths

        paths = []

        @environment.require_paths.each do |p|
          dir = File.join(@environment.root, p)
          paths << dir

          opal_dir = File.join dir, 'opal'
          paths << opal_dir if File.exists? opal_dir
        end

        @environment.specs.each do |spec|
          gemspec = @environment.find_spec spec
          next unless gemspec

          gemspec.require_paths.each do |r|
            dir = File.join(gemspec.full_gem_path, r)
            paths << dir

            opal_dir = File.join dir, 'opal'
            paths << opal_dir if File.exists? opal_dir
          end
          #paths.push *gemspec.load_paths
        end

        @paths = @context.v8.eval paths.inspect
      end

      ##
      # Require a file from context

      def require path, paths
        resolved = find_lib path, paths

        return nil unless resolved

        return false if @cache[resolved]

        @cache[resolved] = true
        @context.v8.eval "opal.FILE = '#{resolved}'"
        @context.eval File.read(resolved), resolved

        resolved
      end

      def find_lib path, paths
        paths.each do |l|
          candidate = File.join l, "#{path}.rb"
          return candidate if File.exists? candidate

          candidate = File.join l, path
          return candidate if File.exists? candidate
        end

        abs = File.expand_path path
        [abs, abs + '.rb'].each do |c|
          return c if File.exists?(c) && !File.directory?(c)
        end

        nil
      end

      ##
      # Build body for given ruby file. Should return a function
      # capable of being executed by opal of form:
      #
      #     function(self, FILE) { ... }

      def file_body(path)
        @context.eval File.read(path), path
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
    end # FileSystem
  end
end
