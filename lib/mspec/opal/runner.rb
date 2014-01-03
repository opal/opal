class OSpecFilter
  def self.main
    @main ||= self.new
  end

  def initialize
    @filters = Set.new
  end

  def register
    MSpec.register :exclude, self
  end

  def ===(description)
    @filters.include? description
  end

  def register_filters(description, block)
    instance_eval(&block)
  end

  def fails(description)
    @filters << description
  end
end

class Object
  def opal_filter(description, &block)
    OSpecFilter.main.register_filters(description, block)
  end
end

class BrowserFormatter
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
    `console.info(str)`
  end

  def red(str)
    `console.error(str)`
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
    `window.OPAL_SPEC_CODE = code;`
  end
end

class PhantomFormatter < BrowserFormatter
  def green(str)
    `console.log('\033[32m' + str + '\033[0m')`
  end

  def red(str)
    `console.log('\033[31m' + str + '\033[0m')`
  end

  def log(str)
    `console.log(str)`
  end
end

module MSpec
  def self.opal_runner
    @env = Object.new
    @env.extend MSpec
  end
end

class OSpecRunner
  def self.main(formatter_class = BrowserFormatter)
    @main ||= self.new formatter_class
  end

  def initialize(formatter_class)
    @formatter_class = formatter_class
    register
    run
  end

  def register
    formatter = @formatter_class.new
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

module OutputSilencer
  def silence_stdout
    original_stdout = $stdout
    new_stdout = IO.new
    new_stdout.extend IO::Writable
    def new_stdout.write(string) end
    begin
      $stdout = new_stdout
      yield
    ensure
      $stdout = original_stdout
    end
  end
end
