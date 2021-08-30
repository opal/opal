# frozen_string_literal: true

require 'opal'
require 'securerandom'
require 'stringio'
require 'fileutils'

module Opal
  class REPL
    HISTORY_PATH = File.expand_path('~/.opal-repl-history')

    def initialize
      begin
        require 'mini_racer'
      rescue LoadError
        abort 'opal-repl depends on mini_racer gem, which is not currently installed'
      end

      begin
        require 'readline'
      rescue LoadError
        abort 'opal-repl depends on readline, which is not currently available'
      end

      MiniRacer::Platform.set_flags! :harmony

      begin
        FileUtils.touch(HISTORY_PATH)
      rescue
        nil
      end
      @history = File.exist?(HISTORY_PATH)
    end

    def run(filename = nil)
      load_opal
      load_file(filename) if filename
      load_history
      run_input_loop
    ensure
      dump_history
    end

    def load_file(filename)
      raise "file does not exist: #{filename}" unless File.exist? filename
      eval_ruby File.read(filename)
    end

    # A polyfill so that SecureRandom works in repl correctly.
    def random_bytes(bytes)
      ::SecureRandom.bytes(bytes).split('').map(&:ord)
    end

    def load_opal
      v8.attach('console.log', method(:print).to_proc)
      v8.attach('console.warn', ->(i) { $stderr.print(i) })
      v8.attach('crypto.randomBytes', method(:random_bytes).to_proc)
      v8.eval Opal::Builder.new.build('opal').to_s
      v8.eval Opal::Builder.new.build('opal/replutils').to_s
      v8.attach('Opal.exit', method(:exit).to_proc)
    end

    def run_line(line)
      result = eval_ruby(line)
      puts result.to_s if result
    end

    def run_input_loop
      # on SIGINT lets just return from the loop..
      previous_trap = trap('SIGINT') { return }

      while (line = readline)
        run_line(line)
      end

    ensure
      trap('SIGINT', previous_trap || 'DEFAULT')
    end

    private

    LINEBREAKS = [
      'unexpected token $end',
      'unterminated string meets end of file'
    ].freeze

    class Silencer
      def initialize
        @stderr = $stderr
      end

      def silence
        @collector = StringIO.new
        $stderr = @collector
        yield
      ensure
        $stderr = @stderr
      end

      def warnings
        @collector.string
      end
    end

    def eval_ruby(code)
      builder = Opal::Builder.new
      silencer = Silencer.new

      code = "#{@incomplete}#{code}"
      if code.start_with? 'ls '
        eval_code = code[3..-1]
        mode = :ls
      elsif code == 'ls'
        eval_code = 'self'
        mode = :ls
      elsif code.start_with? 'show '
        eval_code = code[5..-1]
        mode = :show
      else
        eval_code = code
        mode = :inspect
      end

      begin
        silencer.silence do
          builder.build_str(eval_code, '(irb)', irb: true, const_missing: true)
        end
        @incomplete = nil
      rescue Opal::SyntaxError => e
        if LINEBREAKS.include?(e.message)
          @incomplete = "#{code}\n"
          return
        else
          @incomplete = nil
          if silencer.warnings.empty?
            return e.full_message
          else
            # Most likely a parser error
            return silencer.warnings
          end
        end
      end
      builder.processed[0...-1].each { |js_code| eval_js js_code.to_s }
      last_processed_file = builder.processed.last.to_s

      return last_processed_file if mode == :show

      result = eval_js <<-JS
        Opal.REPLUtils.$eval_and_print(function () {
          var ret = #{last_processed_file};
          return ret;
        }, #{mode.to_s.inspect});
      JS
      result
    rescue Exception => e # rubocop:disable Lint/RescueException
      puts e.full_message(highlight: true)
    end

    def eval_js(code)
      v8.eval(code)
    end

    def v8
      @v8 ||= MiniRacer::Context.new
    end

    def readline
      prompt = @incomplete ? '.. ' : '>> '
      Readline.readline prompt, true
    end

    def load_history
      return unless @history
      File.read(HISTORY_PATH).lines.each { |line| Readline::HISTORY.push line.strip }
    end

    def dump_history
      return unless @history
      length = Readline::HISTORY.size > 1000 ? 1000 : Readline::HISTORY.size
      File.write(HISTORY_PATH, Readline::HISTORY.to_a[-length..-1].join("\n"))
    end
  end
end
