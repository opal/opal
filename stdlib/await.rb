# helpers: coerce_to
# await: await
# backtick_javascript: true

%x{
  var AsyncFunction = Object.getPrototypeOf(async function() {}).constructor;
}

require 'promise/v2'

class Array
  def map_await(&block)
    i = 0
    results = []
    while i < `self.length`
      results << yield(self[i]).await
      i += 1
    end
    results
  end

  def each_await(&block)
    i = 0
    while i < `self.length`
      yield(self[i]).await
      i += 1
    end
    self
  end
end

module Enumerable
  def each_async(&block)
    PromiseV2.when(*map(&block)).await
  end
end

module Kernel
  # Overwrite Kernel.exit to be async-capable.
  def exit(status = true)
    $__at_exit__ ||= []

    until $__at_exit__.empty?
      block = $__at_exit__.pop
      block.call.await
    end

    %x{
      if (status.$$is_boolean) {
        status = status ? 0 : 1;
      } else {
        status = $coerce_to(status, #{Integer}, 'to_int')
      }

      Opal.platform.exit(status);
    }
    nil
  end

  def sleep(seconds)
    prom = PromiseV2.new
    `setTimeout(#{proc { prom.resolve }}, #{seconds * 1000})`
    prom
  end

  alias await itself
end

class Proc
  def async?
    `self instanceof AsyncFunction`
  end
end

class Method
  def async?
    @method.async?
  end
end

class BasicObject
  def instance_exec_await(*args, &block)
    ::Kernel.raise ::ArgumentError, 'no block given' unless block

    # The awaits are defined inside an x-string. Opal can't find them
    # reliably and async-ify a method. Therefore, let's make Opal know
    # this is an async method.
    nil.__await__

    %x{
      var block_self = block.$$s,
          result;

      block.$$s = null;

      if (self.$$is_a_module) {
        self.$$eval = true;
        try {
          result = await block.apply(self, args);
        }
        finally {
          self.$$eval = false;
        }
      }
      else {
        result = await block.apply(self, args);
      }

      block.$$s = block_self;

      return result;
    }
  end
end
