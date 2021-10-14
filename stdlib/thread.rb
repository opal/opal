# use_strict: true
# frozen_string_literal: true

# This shim implementation of Thread is meant to only appease code that tries
# to be safe in the presence of threads, but does not actually utilize them,
# e.g., uses thread- or fiber-local variables.

class ThreadError < StandardError
end

class Thread
  def self.current
    unless @current
      @current = allocate
      @current.core_initialize!
    end

    @current
  end

  def self.list
    [current]
  end

  # Do not allow creation of new instances.
  def initialize(*args)
    raise NotImplementedError, 'Thread creation not available'
  end

  # fiber-local attribute access.
  def [](key)
    @fiber_locals[coerce_key_name(key)]
  end

  def []=(key, value)
    @fiber_locals[coerce_key_name(key)] = value
  end

  def key?(key)
    @fiber_locals.key?(coerce_key_name(key))
  end

  def keys
    @fiber_locals.keys
  end

  # thread-local attribute access.
  def thread_variable_get(key)
    @thread_locals[coerce_key_name(key)]
  end

  def thread_variable_set(key, value)
    @thread_locals[coerce_key_name(key)] = value
  end

  def thread_variable?(key)
    @thread_locals.key?(coerce_key_name(key))
  end

  def thread_variables
    @thread_locals.keys
  end

  private

  def core_initialize!
    @thread_locals = {}
    @fiber_locals  = {}
  end

  def coerce_key_name(key)
    Opal.coerce_to!(key, String, :to_s)
  end

  class Queue
    def initialize
      clear
    end

    def clear
      @storage = []
    end

    def empty?
      @storage.empty?
    end

    def size
      @storage.size
    end

    alias length size

    def pop(non_block = false)
      if empty?
        raise ThreadError, 'Queue empty' if non_block
        raise ThreadError, 'Deadlock'
      end

      @storage.shift
    end

    alias shift pop
    alias deq   pop

    def push(value)
      @storage.push(value)
    end

    alias <<  push
    alias enq push

    def each(&block)
      @storage.each(&block)
    end
  end

  class Backtrace
    class Location
      def initialize(str)
        @str = str

        str =~ /^(.*?):(\d+):(\d+):in `(.*?)'$/
        @path = Regexp.last_match(1)
        @label = Regexp.last_match(4)
        @lineno = Regexp.last_match(2).to_i

        @label =~ /(\w+)$/
        @base_label = Regexp.last_match(1) || @label
      end

      def to_s
        @str
      end

      def inspect
        @str.inspect
      end

      attr_reader :base_label, :label, :lineno, :path

      # TODO: Make it somehow provide the absolute path.
      alias absolute_path path
    end
  end
end

Queue = Thread::Queue

class Mutex
  def initialize
    # We still keep the @locked state so any logic based on try_lock while
    # held yields reasonable results.
    @locked = false
  end

  def lock
    raise ThreadError, 'Deadlock' if @locked
    @locked = true
    self
  end

  def locked?
    @locked
  end

  def owned?
    # Being the only "thread", we implicitly own any locked mutex.
    @locked
  end

  def try_lock
    if locked?
      false
    else
      lock
      true
    end
  end

  def unlock
    raise ThreadError, 'Mutex not locked' unless @locked
    @locked = false
    self
  end

  def synchronize
    lock
    begin
      yield
    ensure
      unlock
    end
  end
end
