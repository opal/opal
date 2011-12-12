require 'opal/environment'

module Opal
  class Context

    attr_reader :v8
    attr_reader :parser
    attr_reader :environment

    ##
    # Glob may be a file or glob path, as a string.

    def self.runner(glob)
      ctx = self.new
      ctx.v8['opal_tmp_glob'] = Dir[glob]

      runner = <<-CODE
        files = `opal_tmp_glob`

        files.each do |a|
          require a
        end
      CODE

      start = Time.now
      ctx.eval_irb runner, '(runner)'
      finish = Time.now
      ctx.finish

      puts "Benchmark runner: #{finish - start}"
    end

    def initialize root = Dir.getwd
      @environment  = Environment.new root
      @root         = root
      @parser       = Opal::Parser.new :debug => true
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
        if line == "exit"
          break
        end

        puts "=> #{eval_irb line, '(irb)'}"
      end

      finish
    end

    def eval_builder(content, file)
      parsed = @parser.parse content, file

      js = "return (#{ parsed })(opal.runtime.top, #{file.inspect})"
      js = @parser.wrap_with_runtime_helpers(js)

      js
    end

    def eval(content, file = "(irb)", line = "")
      @v8.eval eval_builder(content, file), file
    end

    def eval_irb(content, file = '(irb)')
      code = <<-CODE
        (function() {
          try {
            var res = #{ eval_builder content, file };

            return res.m$inspect();
          }
          catch (e) {
            opal.runtime.bt(e);
            return "nil";
          }
        })()
      CODE

      @v8.eval code, file
    end

    # Finishes the context, i.e. tidy everything up. This will cause
    # the opal runtime to do it's at_exit() calls (if applicable) and
    # then the v8 context will de removed. It can be reset by calling
    # #setup_v8
    def finish
      return unless @v8
      @v8.eval "opal.runtime.do_at_exit()", "(irb)"

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
      src = File.read Opal::OPAL_DEBUG_PATH

      @v8.eval src, '(runtime)'
    end

    ##
    # Load gem specific runtime.

    def load_gem_runtime
      dir = File.join OPAL_DIR, 'runtime', 'gemlib'
      order = File.read(File.join dir, 'load_order').strip.split("\n")
      order.each do |f|
        path = File.join dir, "#{f}.rb"
        eval File.read(path), path
      end
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

        paths = [File.join(OPAL_DIR, 'runtime', 'stdlib')]

        @environment.specs.each do |spec|
          paths.push *spec.load_paths
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
        @context.eval File.read(resolved), resolved

        true
      end

      def find_lib path, paths
        paths.each do |l|
          candidate = File.join l, "#{path}.rb"
          return candidate if File.exists? candidate

          candidate = File.join l, path
          return candidate if File.exists? candidate

          candidate = File.expand_path path
          return candidate if File.exists? candidate

          candidate = File.expand_path("#{path}.rb")
          return candidate if File.exists? candidate
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