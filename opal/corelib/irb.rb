# backtick_javascript: true
# helpers: platform

# Debug is a helper module that allows us to conduct some debugging on
# a live codebase. It goes with an assumption, that opal-parser or
# opal-replutils will not be loaded, in which case we will do what we can
# to provision it.

module Opal
  module IRB
    def self.ensure_loaded(library)
      return if `Opal.loaded_features`.include? library

      version = if RUBY_ENGINE_VERSION.include? 'dev'
                  'master'
                else
                  RUBY_ENGINE_VERSION
                end

      url = "https://cdn.opalrb.com/opal/#{version}/#{library}.js"

      %x{
        var libcode;

        if (typeof XMLHttpRequest !== 'undefined') { // Browser
          var r = new XMLHttpRequest();
          r.open("GET", url, false);
          r.send('');
          libcode = r.responseText;
        }
        else {
          #{::Kernel.raise "You need to provision #{library} yourself in this environment"}
        }

        (new Function('Opal', libcode))(Opal);

        Opal.require(library);
      }

      ::Kernel.raise "Could not load #{library} for some reason" unless `Opal.loaded_features`.include? library
    end

    singleton_class.attr_accessor :output

    def self.prepare_console(&block)
      self.output = ''

      original = {
        $stdout => ->(i) { $stdout = i },
        $stderr => ->(i) { $stderr = i },
      }

      # Prepare a better prompt experience for a browser
      if browser?
        original.each do |pipe, pipe_setter|
          new_pipe = pipe.dup
          new_pipe.write_proc = proc do |str|
            self.output += str
            self.output = output.split("\n").last(30).join("\n")
            self.output += "\n" if str.end_with? "\n"

            pipe.write_proc.call(str)
          end
          new_pipe.tty = false
          pipe_setter.call(new_pipe)
        end

      end

      yield
    ensure
      original.each do |pipe, pipe_setter|
        pipe_setter.call(pipe)
      end
      self.output = ''
    end

    def self.browser?
      `Opal.platform.is_browser`
    end

    LINEBREAKS = [
      'unexpected token $end',
      'unterminated string meets end of file'
    ].freeze

    class Silencer
      def initialize
        @stderr = $stderr
      end

      def silence
        @collector = ::StringIO.new
        $stderr = @collector
        yield
      ensure
        $stderr = @stderr
      end

      def warnings
        @collector.string
      end
    end
  end
end

class ::Binding
  def irb
    ::Opal::IRB.ensure_loaded('opal-replutils')

    silencer = ::Opal::IRB::Silencer.new

    ::Opal::IRB.prepare_console do
      loop do
        print '>> '
        line = gets
        break unless line
        code = ''

        puts line if ::Opal::IRB.browser?

        if line.start_with? 'ls '
          code = line[3..-1]
          mode = :ls
        elsif line == "ls\n"
          code = 'self'
          mode = :ls
        elsif line.start_with? 'show '
          code = line[5..-1]
          mode = :show
        else
          code = line
          mode = :inspect
        end

        js_code = nil

        begin
          silencer.silence do
            js_code = `Opal.compile(code, {irb: true})`
          end
        rescue SyntaxError => e
          if ::Opal::IRB::LINEBREAKS.include?(e.message)
            print '.. '
            line = gets
            return unless line
            puts line if ::Opal::IRB.browser?
            code += line
            retry
          elsif silencer.warnings.empty?
            warn e.full_message
          else
            # Most likely a parser error
            warn silencer.warnings
          end
        end

        if mode == :show
          puts js_code
          return
        end

        puts ::REPLUtils.eval_and_print(js_code, mode, false, self).__await__
      end
    end
  end
end

%x{
  // Run in WebTools console with: Opal.irb(c => eval(c))
  Opal.irb = function(fun) {
    #{::Binding.new(`fun`).irb}
  }

  Opal.load_parser = function() {
    Opal.Opal.IRB.$ensure_loaded('opal-parser');
  }

  if (typeof Opal.eval === 'undefined') {
    Opal.eval = function(str) {
      Opal.load_parser();
      return Opal.eval(str);
    }
  }

  if (typeof Opal.compile === 'undefined') {
    Opal.compile = function(str, options) {
      Opal.load_parser();
      return Opal.compile(str, options);
    }
  }
}
