# This file should only be required as needed. This file relies on v8,
# therubyracer. As this is not an essential feature of opal, this file
# will be loaded as needed, and when it is, an error is just thrown if
# the required gems are not installed.
begin
  require 'v8'
rescue LoadError => e
  abort "therubyracer is required for running javascript. Install it with `gem install therubyracer`"
end

require 'opal/context/loader'
require 'opal/context/console'
require 'opal/context/file_system'

module Opal
  class Context < V8::Context

    RUNTIME_PATH = File.expand_path File.join('..', '..', '..', 'runtime.js'), __FILE__

    def initialize(opts = {})
      super opts
      setup_context
    end

    # Setup the context. This basically loads opal.js into our context, and
    # replace the loader etc with our custom loader for a Ruby environment. The
    # default "browser" loader cannot access files from disk.
    def setup_context
      self['console'] = Console.new
      load RUNTIME_PATH

      opal = self['opal']
      opal['loader'] = Loader.new opal, self
      opal['fs'] = FileSystem.new opal, self
      opal['platform']['engine'] = 'opal-gem'

      # eval "opal.require('core');", "(opal)"
      require_file 'core'
    end

    # Require the given id as if it was required in the context. This simply
    # passes the require through to the underlying context.
    def require_file(path)
      eval "opal.require('#{path}');", "(opal)"
    end

    # Set ARGV for the context
    def argv=(args)
      puts "setting argv to #{args.inspect}"
      eval "opal.runtime.cs(opal.runtime.Object, 'ARGV', #{args.inspect});"
    end

    # Start normal js repl
    def start_repl
      require 'readline'

      loop do
        line = Readline.readline '>> ', true
        puts "=> #{eval_ruby line, '(opal)'}"
      end
    end

    def eval_ruby(content, line = "")
      begin
        code = Opal::RubyParser.new(content).parse!.generate_top
        code = "(function() {var $rb = opal.runtime, self = $rb.top, __FILE__ = '(opal)';" + code + "})()"
        # puts code
        self['$opal_irb_result'] = eval code, line
        # self['$code'].to_s + "ww"
        eval "!$opal_irb_result.m$inspect.$rbMM ? $opal_irb_result.m$inspect() : '(Object doesnt support #inspect)'"
      rescue => e
        puts e
        puts("\t" + e.backtrace.join("\n\t"))
      end
    end
  end

end

