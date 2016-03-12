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
    exit(code)
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

class InvertedFormatter < DottedFormatter
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
    unless exception?
      @actually_passing << @current_state
    end

    super
  end

  def finish
    puts "\n\nExpected to fail:\n"
    @actually_passing.each_with_index do |example, idx|
      puts "  #{idx + 1}) #{example.description.inspect}"
    end
    puts "\n"
  end
end
