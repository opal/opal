# frozen_string_literal: true

require 'opal'
require 'securerandom'

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
      v8.attach('console.log', method(:puts).to_proc)
      v8.attach('console.warn', method(:warn).to_proc)
      v8.attach('crypto.randomBytes', method(:random_bytes).to_proc)
      v8.eval Opal::Builder.new.build('opal').to_s
      v8.attach('Opal.exit', method(:exit).to_proc)
    end

    def run_line(line)
      result = eval_ruby(line)
      puts "=> #{result}"
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

    def eval_ruby(code)
      builder = Opal::Builder.new
      builder.build_str(code, '(irb)', irb: true, const_missing: true)
      builder.processed[0...-1].each { |js_code| eval_js js_code.to_s }
      last_processed_file = builder.processed.last.to_s
      eval_js <<-JS
        var $_result = #{last_processed_file};
        $_result.$inspect()
      JS
    rescue => e
      puts "#{e.message}\n\t#{e.backtrace.join("\n\t")}"
    end

    def eval_js(code)
      v8.eval(code)
    end

    def v8
      @v8 ||= MiniRacer::Context.new
    end

    def readline
      Readline.readline '>> ', true
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
