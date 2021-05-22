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
      `Promise.allSettled(#{promises})`.tap do |prom|
        prom.instance_variable_set(:@type, :when)
      end
    end

    def all(*promises)
      `Promise.all(#{promises})`.tap do |prom|
        prom.instance_variable_set(:@type, :all)
      end
    end

    def any(*promises)
      `Promise.any(#{promises})`.tap do |prom|
        prom.instance_variable_set(:@type, :any)
      end
    end

    def race(*promises)
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
    return if %i[reject resolve].include? @type
    raise ArgumentError, 'this promise is native to JavaScript' if native?
  end

  # Allow only one chain to be present, as needed by the previous implementation.
  # This isn't a strict check - it's always possible on the JS side to chain a
  # given block.
  def there_can_be_only_one!
    raise ArgumentError, 'a promise has already been chained' if @chained
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
    @chained = true
    `self.then(#{block})`
  end

  def then!(&block)
    there_can_be_only_one!
    self.then(&block)
  end

  alias then! then
  alias do then
  alias do! then!

  def fail(&block)
    @chained = true
    `self.catch(#{block})`
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
    @chained = true
    `self.finally(#{block})`
  end

  def always!(&block)
    there_can_be_only_one!
    always(&block)
  end

  alias finally always
  alias ensure always
  alias finally! always!
  alias ensure! always!

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
    light_nativity_check!
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

  def initialize(&block)
    yield self if block_given?
  end

  alias to_n itself

  include Enumerable
  def each(&block)
    return enum_for(:each) unless block_given?

    self.then do |res|
      res.each(&block)
    end
  end

  def inspect
    result = "#<#{self.class}"

    if @type
      result += ":#{@type}" unless %i[opal resolve reject].include? @type
    else
      result += ":native"
    end

    result += ":#{@realized}" if @realized
    result += "(#{object_id})"
    result += ": #{@value.inspect}" if @value
    result += ">"

    result
  end
end
