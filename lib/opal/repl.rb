# frozen_string_literal: true

require 'opal'
require 'securerandom'
require 'stringio'
require 'fileutils'

module Opal
  class REPL
    HISTORY_PATH = File.expand_path('~/.opal-repl-history')

    attr_accessor :colorize

    def initialize
      @argv = []
      @colorize = true

      begin
        require 'readline'
      rescue LoadError
        abort 'opal-repl depends on readline, which is not currently available'
      end

      begin
        FileUtils.touch(HISTORY_PATH)
      rescue
        nil
      end
      @history = File.exist?(HISTORY_PATH)
    end

    def run(argv = [])
      @argv = argv

      savepoint = save_tty
      load_opal
      load_history
      run_input_loop
    ensure
      dump_history
      restore_tty(savepoint)
    end

    def load_opal
      runner = @argv.reject { |i| i == '--repl' }
      runner += ['-e', 'require "opal/repl_js"']
      runner = %w[bundle exec opal] + runner

      @pipe = IO.popen(runner, 'r+',
        # What I try to achieve here: let the runner ignore
        # interrupts. Those should be handled by a supervisor.
        pgroup: true,
        new_pgroup: true,
      )
    end

    def run_input_loop
      while (line = readline)
        eval_ruby(line)
      end
    rescue Interrupt
      @incomplete = nil
      retry
    ensure
      finish
    end

    def finish
      @pipe.close
    rescue
      nil
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
        else
          @incomplete = nil
          if silencer.warnings.empty?
            warn e.full_message
          else
            # Most likely a parser error
            warn silencer.warnings
          end
        end
        return
      end
      builder.processed[0...-1].each { |js_code| eval_js(:silent, js_code.to_s) }
      last_processed_file = builder.processed.last.to_s

      if mode == :show
        puts last_processed_file
        return
      end

      eval_js(mode, last_processed_file)
    rescue Interrupt, SystemExit => e
      raise e
    rescue Exception => e # rubocop:disable Lint/RescueException
      puts e.full_message(highlight: true)
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

    def eval_js(mode, code)
      obj = { mode: mode, code: code, colors: colorize }.to_json
      @pipe.puts obj
      while (line = @pipe.readline)
        break if line.chomp == '<<<ready>>>'
        puts line
      end
    rescue Interrupt => e
      # A child stopped responding... let's create a new one
      warn "* Killing #{@pipe.pid}"
      Process.kill('-KILL', @pipe.pid)
      load_opal
      raise e
    rescue EOFError, Errno::EPIPE
      exit $?.exitstatus
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

    # How do we support Win32?
    def save_tty
      %x{stty -g}.chomp
    rescue
      nil
    end

    def restore_tty(savepoint)
      system('stty', savepoint)
    rescue
      nil
    end
  end
end
