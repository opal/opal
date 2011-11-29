require 'yaml'

module Opal
  class Context

    attr_reader :v8

    attr_reader :parser

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

    # Options are mainly just passed onto the builder/parser.
    def initialize(options = {})
      @options      = options
      @root_dir     = options[:dir] || Dir.getwd
      @parser       = Opal::Parser.new
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

            return res.$m.inspect(res);
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
      src = File.read Opal::OPAL_JS_PATH

      @v8.eval src, '(runtime)'
    end

    ##
    # Load gem specific runtime.

    def load_gem_runtime
      dir = File.join OPAL_DIR, 'corelib', 'gem'
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

      def initialize(context)
        @context = context
        @cache = {}
      end

      ##
      # Used to bootstrap loadpaths.

      def find_paths
        return @paths if @paths

        paths = [File.join(OPAL_DIR, "stdlib")]

        Dir['vendor/opal/*'].each do |v|
          lib = File.expand_path(File.join v, 'lib')
          next unless File.directory?(v) and File.directory?(lib)
          paths << lib
        end

        @paths = @context.v8.eval paths.inspect
      end

      ##
      # Require a file from context

      def require(path, paths)
        resolved = find_lib path, paths

        return nil unless resolved

        return false if @cache[resolved]

        @cache[resolved] = true
        @context.eval File.read(resolved), resolved

        true
      end

      def find_lib(path, paths)
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
        @parsed = @context.parser.parse File.read(filename)
        @parsed[:code]
      end

      def wrap(content, filename)
        @context.v8.eval "#{ @context.parser.build_parse_data @parsed}"
        code = @context.v8.eval "(#{@context.parser.wrap_with_runtime_helpers(content)})", filename
        code
      end
    end
  end
end

