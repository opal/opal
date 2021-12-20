# helpers: breaker

class Enumerator
  class Generator
    include ::Enumerable

    def initialize(&block)
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
          if (e === $breaker) {
            return $breaker.$v;
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
