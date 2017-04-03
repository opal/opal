class BaseOpalFormatter
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

  def red(str)
    `console.error(str)`
  end

  def green(str)
    `console.info(str)`
  end

  def cyan(str)
    `console.info(str)`
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
      green "#{@examples} examples, #{@count} failures (time taken: #{time})\n"

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

      log "\n\nFilters for failed examples:\n\n"
      @exceptions.map do |exception|
        ["#{exception.describe} #{exception.it}", exception.message.tr("\n", " ")]
      end.sort.each do |(description, message)|
        red "fails #{description.inspect}"
        cyan " # #{message}\n"
      end
      log "\n"

      finish_with_code(1)
    end
  end

  def finish_with_code(code)
    exit(code)
  end
end

class BrowserFormatter < BaseOpalFormatter
  def initialize(*args, &block)
    $passed = 0
    $failed = 0
    $errored = 0
    super
  end

  def print_example(state)
    unless exception?
      $passed += 1
    else
      if failure?
        $failed += 1
      else
        $errored += 1
      end
    end
  end
end

class PhantomFormatter < BaseOpalFormatter
  def red(str)
    `console.log('\u001b[31m' + str + '\u001b[0m')`
  end

  def green(str)
    `console.log('\u001b[32m' + str + '\u001b[0m')`
  end

  def cyan(str)
    `console.log('\u001b[36m' + str + '\u001b[0m')`
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

class NodeJSFormatter < BaseOpalFormatter
  def initialize(*args, &block)
    require 'nodejs/stacktrace'
    super
  end

  def red(str)
    `process.stdout.write("\u001b[31m"+#{str}+"\u001b[0m")`
  end

  def green(str)
    `process.stdout.write("\u001b[32m"+#{str}+"\u001b[0m")`
  end

  def cyan(str)
    `process.stdout.write("\u001b[36m"+#{str}+"\u001b[0m")`
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

module InvertedFormatter
  def initialize(out=nil)
    super
    @actually_passing = []
  end

  def register
    MSpec.register :before, self
    MSpec.register :exception, self
    MSpec.register :after, self
    MSpec.register :finish, self
  end

  def after(state=nil)
    @actually_passing << @current_state unless exception?
    super
  end

  def finish
    puts "\n\nExpected #{@actually_passing.size} examples to fail:\n"
    @actually_passing.each_with_index do |example, idx|
      puts "  #{idx + 1}) #{example.description.inspect}"
    end
    puts "\n"
  end
end
