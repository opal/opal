module Opal
  class Context

    attr_reader :v8
    attr_reader :parser

    def initialize
      @parser = Parser.new
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
      @parser.parse content, file
    end

    def eval(content, file = "(irb)", line = "")
      @v8.eval eval_builder(content, file), file
    end

    def eval_irb(content, file = '(irb)')
      code = <<-CODE
        (function() { try {
          var res = #{ eval_builder content, file };
          return res.$inspect();
         }
         catch (e) {
           console.log(e.$backtrace().join("\\n\\t"));
           return "nil";
         }
        })()
      CODE

      @v8.eval code, file

    rescue V8::JSError => e
      puts "SyntaxError: #{e.message}"
      "nil"
    rescue => e
      puts "ParseError: #{e.message}"
      "nil"
    end

    def finish
      @v8 = nil
    end

    def setup_v8
      return if @v8

      begin
        require 'v8'
      rescue LoadError => e
        abort "therubyracer is required for running javascript. Install it with `gem install therubyracer`"
      end

      @v8            = V8::Context.new
      console        = Object.new
      @v8['console'] = console

      def console.log(*str)
        puts str.join("\n")
        nil
      end

      @v8.eval File.read(Opal.runtime_path), '(opal.js)'
    end
  end
end