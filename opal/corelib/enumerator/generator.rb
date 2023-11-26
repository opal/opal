# helpers: deny_frozen_access
# backtick_javascript: true
# use_strict: true

class Enumerator
  class Generator
    include ::Enumerable

    def initialize(&block)
      `$deny_frozen_access(self)`

      ::Kernel.raise ::LocalJumpError, 'no block given' unless block

      @block = block
    end

    def each(*args, &block)
      yielder = Yielder.new(&block)

      %x{
        try {
          args.unshift(#{yielder});

          Opal.yieldX(#{@block}, args);
        }
        catch (e) {
          if (e && e.$thrower_type == "breaker") {
            return e.$v;
          }
          else {
            throw e;
          }
        }
      }

      self
    end
  end
end
