# stdlib
require 'date'
require 'observer'

ENV['MSPEC_RUNNER'] = true

class OSpecFilter
  def self.main
    @main ||= self.new
  end

  def initialize
    @filters = {}
  end

  def register
    MSpec.register :exclude, self
  end

  def ===(description)
    @filters.has_key? description
  end

  def register_filters(description, block)
    instance_eval(&block)
  end

  def fails(description)
    @filters[description] = true
  end
end

class Object
  def opal_filter(description, &block)
    OSpecFilter.main.register_filters(description, block)
  end
end

class PhantomFormatter
  def initialize(out=nil)
    @exception = @failure = false
    @exceptions = []
    @count = 0
    @examples = 0

    @current_state = nil
  end

  def register
    MSpec.register :exception, self
    MSpec.register :before,    self
    MSpec.register :after,     self
    MSpec.register :start,     self
    MSpec.register :finish,    self
    MSpec.register :abort,     self
    MSpec.register :enter,     self
  end

  def green(str)
    `console.log('\\033[32m' + str + '\\033[0m')`
  end

  def red(str)
    `console.log('\\033[31m' + str + '\\033[0m')`
  end

  def log(str)
    `console.log(str)`
  end

  def exception?
    @exception
  end

  def failure?
    @failure
  end

  def enter(describe); end

  def before(state=nil)
    @current_state = nil
    @failure = @exception = false
  end

  def exception(exception)
    @count += 1
    @failure = @exception ? @failure && exception.failure? : exception.failure?
    @exception = true
    @exceptions << exception
  end

  def after(state = nil)
    @current_state = nil
    @examples += 1
  end

  def start
    @start_time = Time.now.to_f
  end

  def finish
    time = Time.now.to_f - @start_time

    if @exceptions.empty?
      log "\nFinished"
      green "#{@examples} examples, #{@count} failures (time taken: #{time})"

      finish_with_code 0
    else
      log "\nFailures:"

      @exceptions.each_with_index do |exception, idx|
        log "\n  #{idx + 1}. #{exception.description}"
        red "\n    #{exception.message}"
      end

      log "\nFinished"
      red "#{@examples} examples, #{@count} failures (time taken: #{time})"

      finish_with_code(1)
    end
  end

  def finish_with_code(code)
    %x{
      if (typeof(phantom) !== 'undefined') {
        return phantom.exit(code);
      }
      else {
        window.OPAL_SPEC_CODE = code;
      }
    }
  end
end

class File
  def self.expand_path(*a); nil; end
end

class ExceptionState
  def initialize(state, location, exception)
    @exception = exception

    @description = location ? ["An exception occurred during: #{location}"] : []
    if state
      @description << "\n" unless @description.empty?
      @description << state.description
      @describe = state.describe
      @it = state.it
      @description = @description.join ""
    else
      @describe = @it = ""
    end
  end
end

module Kernel
  def opal_eval(str)
    code = Opal::Parser.new.parse str
    `eval(#{code})`
  end

  def opal_parse(str, file='(string)')
    Opal::Grammar.new.parse str, file
  end

  def opal_eval_compiled(javascript)
    `eval(javascript)`
  end

  def eval(str)
    opal_eval str
  end
end

module Kernel
  # FIXME: remove
  def pending(*); end
  def language_version(*); end
end

module MSpec
  def self.opal_runner
    @env = Object.new
    @env.extend MSpec
  end
end

class OSpecRunner
  def self.main
    @main ||= self.new
  end

  def initialize
    register
    run
  end

  def register
    formatter = PhantomFormatter.new
    formatter.register

    OSpecFilter.main.register
  end

  def run
    MSpec.opal_runner
  end

  def will_start
    MSpec.actions :start
  end

  def did_finish
    MSpec.actions :finish
  end
end

# As soon as this file loads, tell the runner the specs are starting
OSpecRunner.main.will_start

