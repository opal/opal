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
        log "\n    #{`#{exception.exception}.stack`}\n"
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

  def after(state)
    super
    unless exception?
      print '.'
    else
      print failure? ? 'F' : 'E'
    end
  end
end

class NodeJSFormatter < BrowserFormatter
  def green(str)
    `process.stdout.write("\033[32m"+#{str}+"\033[0m")`
  end

  def red(str)
    `process.stdout.write("\033[31m"+#{str}+"\033[0m")`
  end

  def log(str)
    puts str
  end

  def after(state)
    super
    print_example(state)
  end

  def print_example(state)
    unless exception?
      green('.')
    else
      red(failure? ? 'F' : 'E')
    end
  end

  def finish_with_code(code)
    `global.OPAL_SPEC_CODE = code;`
  end

  def finish_with_code(code)
    puts "\n\n"
    exit(code)
  end
end

class PhantomDocFormatter < PhantomFormatter
  def after(state = nil)
    (@exception && state) ? red(state.description) : green(state.description)
    super
  end
end

class NodeJSDocFormatter < NodeJSFormatter
  def print_example(state)
    (@exception && state) ? red(state.description+"\n") : green(state.description+"\n")
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

  def bm!(repeat)
    `self.bm = {}`
    MSpec.repeat = repeat;
    MSpec.register :before, self
    MSpec.register :after,  self
  end

  def before(state = nil)
    %x{
      if (self.bm && !self.bm.hasOwnProperty(state.description)) {
        self.bm[state.description] = {started: Date.now()};
      }
    }
  end

  def after(state = nil)
    %x{
      if (self.bm) {
        self.bm[state.description].stopped = Date.now();
      }
    }
  end

  def did_finish
    %x{
      var obj = self.bm, key, val, json, file;
      if (obj) {
        for (key in obj) {
          if (obj.hasOwnProperty(key)) {
            val = obj[key];
            obj[key] = val.stopped - val.started;
          }
        }
        json = JSON.stringify(obj, null, '  ');
        file = #{Time.now.strftime('tmp/bm_%Y-%m-%d_%H-%M-%S-%L.json')};
        #{File.open(`file`, 'w') {|f| f.write(`json`)}}
      }
    }
    MSpec.actions :finish
  end
end

module OutputSilencer
  def silence_stdout
    original_stdout = $stdout
    new_stdout = IO.new
    new_stdout.extend IO::Writable
    new_stdout.write_proc = ->s{}

    begin
      $stdout = new_stdout
      yield
    ensure
      $stdout = original_stdout
    end
  end
end
