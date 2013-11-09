class Enumerator
  include Enumerable

  def initialize(obj = undefined, method = :each, *args, &block)
    if block
      @size   = obj
      @object = Generator.new(&block)
      @method = :each
    else
      if `obj === undefined`
        raise ArgumentError, "wrong number of arguments (0 for 1+)"
      end

      @size   = nil
      @object = obj
      @method = method
      @args   = args
    end
  end

  def each(&block)
    return self unless block

    @object.__send__(@method, *@args, &block)
  end

  def size
    Proc === @size ? @size.call : @size
  end

  def inspect
    "#<#{self.class.name}: #{@object.inspect}:#{@method}>"
  end

  class Generator
    include Enumerable

    def initialize(&block)
      raise LocalJumpError, 'no block given' unless block

      @block = block
    end

    def each(*args, &block)
      yielder = Yielder.new(&block)

      %x{
        try {
          args.unshift(#{yielder});

          if ($opal.$yieldX(#@block, args) === $breaker) {
            return $breaker.$v;
          }
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

  class Yielder
    def initialize(&block)
      @block = block
    end

    def yield(*values)
      %x{
        if ($opal.$yieldX(#@block, values) === $breaker) {
          throw $breaker;
        }
      }

      self
    end

    alias << yield
  end

  class Lazy < self
    class StopLazyError < Exception; end

    def initialize(object, size = nil, &block)
      unless block_given?
        raise ArgumentError, 'tried to call lazy new without a block'
      end

      @enumerator = object

      super size do |yielder, *each_args|
        begin
          object.each(*each_args) {|*args|
            %x{
              args.unshift(#{yielder});

              if ($opal.$yieldX(block, args) === $breaker) {
                return $breaker;
              }
            }
          }
        rescue Exception
          nil
        end
      end
    end

    alias force to_a

    def lazy
      self
    end

    def collect(&block)
      unless block
        raise ArgumentError, 'tried to call lazy map without a block'
      end

      Lazy.new(self, enumerator_size) {|enum, *args|
        %x{
          var value = $opal.$yieldX(block, args);

          if (value === $breaker) {
            return $breaker;
          }

          #{enum.yield `value`};
        }
      }
    end

    def drop(n)
      n = Opal.coerce_to n, Integer, :to_int

      if n < 0
        raise ArgumentError, "attempt to drop negative size"
      end

      current_size = enumerator_size
      set_size     = if Integer === current_size
        n < current_size ? n : current_size
      else
        current_size
      end

      dropped = 0
      Lazy.new(self, set_size) {|enum, *args|
        if dropped < n
          dropped += 1
        else
          enum.yield(*args)
        end
      }
    end

    def drop_while(&block)
      unless block
        raise ArgumentError, 'tried to call lazy drop_while without a block'
      end

      succeeding = true
      Lazy.new(self, nil) {|enum, *args|
        if succeeding
          %x{
            var value = $opal.$yieldX(block, args);

            if (value === $breaker) {
              return $breaker;
            }

            if (#{Opal.falsy?(`value`)}) {
              succeeding = false;

              #{enum.yield(*args)};
            }
          }
        else
          enum.yield(*args)
        end
      }
    end

    def find_all(&block)
      unless block
        raise ArgumentError, 'tried to call lazy select without a block'
      end

      Lazy.new(self, nil) {|enum, *args|
        %x{
          var value = $opal.$yieldX(block, args);

          if (value === $breaker) {
            return $breaker;
          }

          if (#{Opal.truthy?(`value`)}) {
            #{enum.yield(*args)};
          }
        }
      }
    end

    alias flat_map collect_concat

    def grep(pattern, &block)
      if block
        Lazy.new(self, nil) {|enum, *args|
          %x{
            var param = #{Opal.destructure(args)},
                value = #{pattern === `param`};

            if (#{Opal.truthy?(`value`)}) {
              value = $opal.$yield1(block, param);

              if (value === $breaker) {
                return $breaker;
              }

              #{enum.yield `$opal.$yield1(block, param)`};
            }
          }
        }
      else
        Lazy.new(self, nil) {|enum, *args|
          %x{
            var param = #{Opal.destructure(args)},
                value = #{pattern === `param`};

            if (#{Opal.truthy?(`value`)}) {
              #{enum.yield `param`};
            }
          }
        }
      end
    end

    alias map collect

    alias select find_all

    def reject(&block)
      unless block
        raise ArgumentError, 'tried to call lazy reject without a block'
      end

      Lazy.new(self, nil) {|enum, *args|
        %x{
          var value = $opal.$yieldX(block, args);

          if (value === $breaker) {
            return $breaker;
          }

          if (#{Opal.falsy?(`value`)}) {
            #{enum.yield(*args)};
          }
        }
      }
    end

    def take(n)
      n = Opal.coerce_to n, Integer, :to_int

      if n < 0
        raise ArgumentError, "attempt to take negative size"
      end

      current_size = enumerator_size
      set_size     = if Integer === current_size
        n < current_size ? n : current_size
      else
        current_size
      end

      taken = 0
      Lazy.new(self, set_size) {|enum, *args|
        if taken < n
          enum.yield(*args)
          taken += 1
        else
          raise StopLazyError
        end
      }
    end

    def take_while(&block)
      unless block
        raise ArgumentError, 'tried to call lazy take_while without a block'
      end

      Lazy.new(self, nil) {|enum, *args|
        %x{
          var value = $opal.$yieldX(block, args);

          if (value === $breaker) {
            return $breaker;
          }

          if (#{Opal.truthy?(`value`)}) {
            #{enum.yield(*args)};
          }
          else {
            #{raise StopLazyError};
          }
        }
      }
    end

    def inspect
      "#<#{self.class.name}: #{@enumerator.inspect}>"
    end
  end
end
