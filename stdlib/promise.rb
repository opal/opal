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

class Promise < `Promise`
  class << self
    def allocate
      ok, fail = nil, nil

      prom = `new self.$$constructor(function(_ok, _fail) { #{ok} = _ok; #{fail} = _fail; })`
      prom.instance_variable_set(:@type, :opal)
      prom.instance_variable_set(:@resolve_proc, ok)
      prom.instance_variable_set(:@reject_proc, fail)
      prom
    end

    def when(*promises)
      promises = Array(promises.length == 1 ? promises.first : promises)
      `Promise.all(#{promises})`.tap do |prom|
        prom.instance_variable_set(:@type, :when)
      end
    end

    alias all when

    def any(*promises)
      promises = Array(promises.length == 1 ? promises.first : promises)
      `Promise.any(#{promises})`.tap do |prom|
        prom.instance_variable_set(:@type, :any)
      end
    end

    def race(*promises)
      promises = Array(promises.length == 1 ? promises.first : promises)
      `Promise.race(#{promises})`.tap do |prom|
        prom.instance_variable_set(:@type, :race)
      end
    end

    def resolve(value = nil)
      `Promise.resolve(#{value})`.tap do |prom|
        prom.instance_variable_set(:@type, :resolve)
        prom.instance_variable_set(:@realized, :resolve)
        prom.instance_variable_set(:@value, value)
      end
    end
    alias value resolve

    def reject(value = nil)
      `Promise.reject(#{value})`.tap do |prom|
        prom.instance_variable_set(:@type, :reject)
        prom.instance_variable_set(:@realized, :reject)
        prom.instance_variable_set(:@value, value)
      end
    end
    alias error reject
  end

  attr_reader :prev, :next

  # Is this promise native to JavaScript? This means, that methods like resolve
  # or reject won't be available.
  def native?
    @type != :opal
  end

  # Raise an exception when a non-JS-native method is called on a JS-native promise
  def nativity_check!
    raise ArgumentError, 'this promise is native to JavaScript' if native?
  end

  # Raise an exception when a non-JS-native method is called on a JS-native promise
  # but permits some typed promises
  def light_nativity_check!
    return if %i[reject resolve trace always fail then].include? @type
    raise ArgumentError, 'this promise is native to JavaScript' if native?
  end

  # Allow only one chain to be present, as needed by the previous implementation.
  # This isn't a strict check - it's always possible on the JS side to chain a
  # given block.
  def there_can_be_only_one!
    raise ArgumentError, 'a promise has already been chained' if @next && @next.any?
  end

  def gen_tracing_proc(passing, &block)
    proc do |i|
      res = passing.(i)
      block.(res)
      res
    end
  end

  def resolve(value = nil)
    nativity_check!
    raise ArgumentError, 'this promise was already resolved' if @realized
    @value = value
    @realized = :resolve
    @resolve_proc.(value)
    self
  end
  alias resolve! resolve

  def reject(value = nil)
    nativity_check!
    raise ArgumentError, 'this promise was already resolved' if @realized
    @value = value
    @realized = :reject
    @reject_proc.(value)
    self
  end
  alias reject! reject

  def then(&block)
    prom = nil
    blk = gen_tracing_proc(block) do |val|
      prom.instance_variable_set(:@realized, :resolve)
      prom.instance_variable_set(:@value, val)
    end
    prom = `self.then(#{blk})`
    prom.instance_variable_set(:@prev, self)
    prom.instance_variable_set(:@type, :then)
    (@next ||= []) << prom
    prom
  end

  def then!(&block)
    there_can_be_only_one!
    self.then(&block)
  end

  alias do then
  alias do! then!

  def fail(&block)
    prom = nil
    blk = gen_tracing_proc(block) do |val|
      prom.instance_variable_set(:@realized, :resolve)
      prom.instance_variable_set(:@value, val)
    end
    prom = `self.catch(#{blk})`
    prom.instance_variable_set(:@prev, self)
    prom.instance_variable_set(:@type, :fail)
    (@next ||= []) << prom
    prom
  end

  def fail!(&block)
    there_can_be_only_one!
    fail(&block)
  end

  alias rescue fail
  alias catch fail
  alias rescue! fail!
  alias catch! fail!

  def always(&block)
    prom = nil
    blk = gen_tracing_proc(block) do |val|
      prom.instance_variable_set(:@realized, :resolve)
      prom.instance_variable_set(:@value, val)
    end
    prom = `self.finally(#{blk})`
    prom.instance_variable_set(:@prev, self)
    prom.instance_variable_set(:@type, :always)
    (@next ||= []) << prom
    prom
  end

  def always!(&block)
    there_can_be_only_one!
    always(&block)
  end

  alias finally always
  alias ensure always
  alias finally! always!
  alias ensure! always!

  def trace(depth = nil, &block)
    self.then do
      values = []
      prom = self
      while prom && (!depth || depth > 0)
        val = nil
        begin
          val = prom.value
        rescue ArgumentError
          val = :native
        end
        values.unshift(val)
        depth -= 1 if depth
        prom = prom.prev
      end
      yield(*values)
    end.tap do |prom|
      prom.instance_variable_set(:@type, :trace)
    end
  end

  def trace!(*args, &block)
    there_can_be_only_one!
    trace(*args, &block)
  end

  def resolved?
    light_nativity_check!
    @realized == :resolve
  end

  def rejected?
    light_nativity_check!
    @realized == :reject
  end

  def realized?
    light_nativity_check!
    !@realized.nil?
  end

  def value
    if resolved?
      if Promise === @value
        @value.value
      else
        @value
      end
    end
  end

  def error
    light_nativity_check!
    @value if rejected?
  end

  def and(*promises)
    promises = promises.map do |i|
      if Promise === i
        i
      else
        Promise.value(i)
      end
    end
    Promise.when(self, *promises).then do |a, *b|
      [*a, *b]
    end
  end

  def initialize(&block)
    yield self if block_given?
  end

  alias to_n itself

  #include Enumerable
  #def each(&block)
  #  return enum_for(:each) unless block_given?
  #
  #  self.then do |res|
  #    res.each(&block)
  #  end
  #end

  def inspect
    result = "#<#{self.class}"

    if @type
      result += ":#{@type}" unless %i[opal resolve reject].include? @type
    else
      result += ":native"
    end

    result += ":#{@realized}" if @realized
    result += "(#{object_id})"

    if @next && @next.any?
      result += " >> #{@next.inspect}"
    end

    result += ": #{@value.inspect}" if @value
    result += ">"

    result
  end
end
