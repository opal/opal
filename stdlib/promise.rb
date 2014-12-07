# {Promise} is used to help structure asynchronous code.
#
# It is available in the Opal standard library, and can be required in any Opal
# application:
#
#     require 'promise'
#
# ## Basic Usage
#
# Promises are created and returned as objects with the assumption that they
# will eventually be resolved or rejected, but never both. A {Promise} has
# a {#then} and {#fail} method (or one of their aliases) that can be used to
# register a block that gets called once resolved or rejected.
#
#     promise = Promise.new
#
#     promise.then {
#       puts "resolved!"
#     }.fail {
#       puts "rejected!"
#     }
#
#     # some time later
#     promise.resolve
#
#     # => "resolved!"
#
# It is important to remember that a promise can only be resolved or rejected
# once, so the block will only ever be called once (or not at all).
#
# ## Resolving Promises
#
# To resolve a promise, means to inform the {Promise} that it has succeeded
# or evaluated to a useful value. {#resolve} can be passed a value which is
# then passed into the block handler:
#
#     def get_json
#       promise = Promise.new
#
#       HTTP.get("some_url") do |req|
#         promise.resolve req.json
#       end
#
#       promise
#     end
#
#     get_json.then do |json|
#       puts "got some JSON from server"
#     end
#
# ## Rejecting Promises
#
# Promises are also designed to handle error cases, or situations where an
# outcome is not as expected. Taking the previous example, we can also pass
# a value to a {#reject} call, which passes that object to the registered
# {#fail} handler:
#
#     def get_json
#       promise = Promise.new
#
#       HTTP.get("some_url") do |req|
#         if req.ok?
#           promise.resolve req.json
#         else
#           promise.reject req
#         end
#
#       promise
#     end
#
#     get_json.then {
#       # ...
#     }.fail { |req|
#       puts "it went wrong: #{req.message}"
#     }
#
# ## Chaining Promises
#
# Promises become even more useful when chained together. Each {#then} or
# {#fail} call returns a new {Promise} which can be used to chain more and more
# handlers together.
#
#     promise.then { wait_for_something }.then { do_something_else }
#
# Rejections are propagated through the entire chain, so a "catch all" handler
# can be attached at the end of the tail:
#
#     promise.then { ... }.then { ... }.fail { ... }
#
# ## Composing Promises
#
# {Promise.when} can be used to wait for more than one promise to resolve (or
# reject). Using the previous example, we could request two different json
# requests and wait for both to finish:
#
#     Promise.when(get_json, get_json2).then |first, second|
#       puts "got two json payloads: #{first}, #{second}"
#     end
#
class Promise
  def self.value(value)
    new.resolve(value)
  end

  def self.error(value)
    new.reject(value)
  end

  def self.when(*promises)
    When.new(promises)
  end

  attr_reader :value, :error, :prev, :next

  def initialize(success = nil, failure = nil)
    @success = success
    @failure = failure

    @realized  = nil
    @exception = false
    @value     = nil
    @error     = nil
    @delayed   = nil

    @prev = nil
    @next = nil
  end

  def act?
    @success != nil
  end

  def exception?
    @exception
  end

  def realized?
    @realized != nil
  end

  def resolved?
    @realized == :resolve
  end

  def rejected?
    @realized == :reject
  end

  def ^(promise)
    promise << self
    self    >> promise

    promise
  end

  def <<(promise)
    @prev = promise

    self
  end

  def >>(promise)
    @next = promise

    if exception?
      promise.reject(@delayed)
    elsif resolved?
      promise.resolve(@delayed || value)
    elsif rejected? && (!@failure || Promise === (@delayed || @error))
      promise.reject(@delayed || error)
    end

    self
  end

  def resolve(value = nil)
    if realized?
      raise ArgumentError, 'the promise has already been realized'
    end

    if Promise === value
      value << @prev

      return value ^ self
    end

    @realized = :resolve
    @value    = value

    begin
      if @success
        value = @success.call(value)
      end

      resolve!(value)
    rescue Exception => e
      exception!(e)
    end

    self
  end

  def resolve!(value)
    if @next
      @next.resolve(value)
    else
      @delayed = value
    end
  end

  def reject(value = nil)
    if realized?
      raise ArgumentError, 'the promise has already been realized'
    end

    if Promise === value
      value << @prev

      return value ^ self
    end

    @realized = :reject
    @error    = value

    begin
      if @failure
        value = @failure.call(value)

        if Promise === value
          reject!(value)
        end
      else
        reject!(value)
      end
    rescue Exception => e
      exception!(e)
    end

    self
  end

  def reject!(value)
    if @next
      @next.reject(value)
    else
      @delayed = value
    end
  end

  def exception!(error)
    @exception = true

    reject!(error)
  end

  def then(&block)
    if @next
      raise ArgumentError, 'a promise has already been chained'
    end

    self ^ Promise.new(block)
  end

  alias do then

  def fail(&block)
    if @next
      raise ArgumentError, 'a promise has already been chained'
    end

    self ^ Promise.new(nil, block)
  end

  alias rescue fail
  alias catch fail

  def always(&block)
    if @next
      raise ArgumentError, 'a promise has already been chained'
    end

    self ^ Promise.new(block, block)
  end

  alias finally always
  alias ensure always

  def trace(depth = nil, &block)
    if @next
      raise ArgumentError, 'a promise has already been chained'
    end

    self ^ Trace.new(depth, block)
  end

  def inspect
    result = "#<#{self.class}(#{object_id})"

    if @next
      result += " >> #{@next.inspect}"
    end

    if realized?
      result += ": #{(@value || @error).inspect}>"
    else
      result += ">"
    end

    result
  end

  class Trace < self
    def self.it(promise)
      unless promise.realized?
        raise ArgumentError, "the promise hasn't been realized"
      end

      current = promise.act? ? [promise.value] : []

      if prev = promise.prev
        current.concat(it(prev))
      else
        current
      end
    end

    def initialize(depth, block)
      @depth = depth

      super -> {
        trace = Trace.it(self).reverse

        if depth && depth <= trace.length
          trace.shift(trace.length - depth)
        end

        block.call(*trace)
      }
    end
  end

  class When < self
    def initialize(promises = [])
      super()

      @wait = []

      promises.each {|promise|
        wait promise
      }
    end

    def each(&block)
      raise ArgumentError, 'no block given' unless block

      self.then {|values|
        values.each(&block)
      }
    end

    def collect(&block)
      raise ArgumentError, 'no block given' unless block

      self.then {|values|
        When.new(values.map(&block))
      }
    end

    def inject(*args, &block)
      self.then {|values|
        values.reduce(*args, &block)
      }
    end

    alias map collect

    alias reduce inject

    def wait(promise)
      unless Promise === promise
        promise = Promise.value(promise)
      end

      if promise.act?
        promise = promise.then
      end

      @wait << promise

      promise.always {
        try if @next
      }

      self
    end

    alias and wait

    def >>(*)
      super.tap {
        try
      }
    end

    def try
      if @wait.all?(&:realized?)
        if promise = @wait.find(&:rejected?)
          reject(promise.error)
        else
          resolve(@wait.map(&:value))
        end
      end
    end
  end
end
