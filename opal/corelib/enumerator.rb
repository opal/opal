require 'corelib/enumerable'

class Enumerator
  include Enumerable

  `self.$$prototype.$$is_enumerator = true`

  def self.for(object, method = :each, *args, &block)
    %x{
      var obj = #{allocate};

      obj.object = object;
      obj.size   = block;
      obj.method = method;
      obj.args   = args;

      return obj;
    }
  end

  def initialize(*, &block)
    if block
      @object = Generator.new(&block)
      @method = :each
      @args   = []
      @size   = `arguments[0] || nil`

      if @size
        @size = Opal.coerce_to @size, Integer, :to_int
      end
    else
      @object = `arguments[0]`
      @method = `arguments[1] || "each"`
      @args   = `$slice.call(arguments, 2)`
      @size   = nil
    end
  end

  def each(*args, &block)
    return self if block.nil? && args.empty?

    args = @args + args

    return self.class.new(@object, @method, *args) if block.nil?

    @object.__send__(@method, *args, &block)
  end

  def size
    Proc === @size ? @size.call(*@args) : @size
  end

  def with_index(offset = 0, &block)
    offset = if offset
               Opal.coerce_to offset, Integer, :to_int
             else
               0
             end

    return enum_for(:with_index, offset) { size } unless block

    %x{
      var result, index = offset;

      self.$each.$$p = function() {
        var param = #{Opal.destructure(`arguments`)},
            value = block(param, index);

        index++;

        return value;
      }

      return self.$each();
    }
  end

  alias with_object each_with_object

  def inspect
    result = "#<#{self.class}: #{@object.inspect}:#{@method}"

    if @args.any?
      result += "(#{@args.inspect[Range.new(1, -2)]})"
    end

    result + '>'
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

  class Yielder
    def initialize(&block)
      @block = block
    end

    def yield(*values)
      %x{
        var value = Opal.yieldX(#{@block}, values);

        if (value === $breaker) {
          throw $breaker;
        }

        return value;
      }
    end

    def <<(*values)
      self.yield(*values)

      self
    end
  end

  class Lazy < self
    class StopLazyError < Exception; end

    def initialize(object, size = nil, &block)
      unless block_given?
        raise ArgumentError, 'tried to call lazy new without a block'
      end

      @enumerator = object

      super size do |yielder, *each_args|
        object.each(*each_args) do |*args|
          %x{
            args.unshift(#{yielder});

            Opal.yieldX(block, args);
          }
        end
      rescue Exception
        nil
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

      Lazy.new(self, enumerator_size) do |enum, *args|
        %x{
          var value = Opal.yieldX(block, args);

          #{enum.yield `value`};
        }
      end
    end

    def collect_concat(&block)
      unless block
        raise ArgumentError, 'tried to call lazy map without a block'
      end

      Lazy.new(self, nil) do |enum, *args|
        %x{
          var value = Opal.yieldX(block, args);

          if (#{`value`.respond_to? :force} && #{`value`.respond_to? :each}) {
            #{`value`.each { |v| enum.yield v }}
          }
          else {
            var array = #{Opal.try_convert `value`, Array, :to_ary};

            if (array === nil) {
              #{enum.yield `value`};
            }
            else {
              #{`value`.each { |v| enum.yield v }};
            }
          }
        }
      end
    end

    def drop(n)
      n = Opal.coerce_to n, Integer, :to_int

      if n < 0
        raise ArgumentError, 'attempt to drop negative size'
      end

      current_size = enumerator_size
      set_size     = if Integer === current_size
                       n < current_size ? n : current_size
                     else
                       current_size
                     end

      dropped = 0
      Lazy.new(self, set_size) do |enum, *args|
        if dropped < n
          dropped += 1
        else
          enum.yield(*args)
        end
      end
    end

    def drop_while(&block)
      unless block
        raise ArgumentError, 'tried to call lazy drop_while without a block'
      end

      succeeding = true
      Lazy.new(self, nil) do |enum, *args|
        if succeeding
          %x{
            var value = Opal.yieldX(block, args);

            if (#{Opal.falsy?(`value`)}) {
              succeeding = false;

              #{enum.yield(*args)};
            }
          }
        else
          enum.yield(*args)
        end
      end
    end

    def enum_for(method = :each, *args, &block)
      self.class.for(self, method, *args, &block)
    end

    def find_all(&block)
      unless block
        raise ArgumentError, 'tried to call lazy select without a block'
      end

      Lazy.new(self, nil) do |enum, *args|
        %x{
          var value = Opal.yieldX(block, args);

          if (#{Opal.truthy?(`value`)}) {
            #{enum.yield(*args)};
          }
        }
      end
    end

    alias flat_map collect_concat

    def grep(pattern, &block)
      if block
        Lazy.new(self, nil) do |enum, *args|
          %x{
            var param = #{Opal.destructure(args)},
                value = #{pattern === `param`};

            if (#{Opal.truthy?(`value`)}) {
              value = Opal.yield1(block, param);

              #{enum.yield `Opal.yield1(block, param)`};
            }
          }
        end
      else
        Lazy.new(self, nil) do |enum, *args|
          %x{
            var param = #{Opal.destructure(args)},
                value = #{pattern === `param`};

            if (#{Opal.truthy?(`value`)}) {
              #{enum.yield `param`};
            }
          }
        end
      end
    end

    alias map collect

    alias select find_all

    def reject(&block)
      unless block
        raise ArgumentError, 'tried to call lazy reject without a block'
      end

      Lazy.new(self, nil) do |enum, *args|
        %x{
          var value = Opal.yieldX(block, args);

          if (#{Opal.falsy?(`value`)}) {
            #{enum.yield(*args)};
          }
        }
      end
    end

    def take(n)
      n = Opal.coerce_to n, Integer, :to_int

      if n < 0
        raise ArgumentError, 'attempt to take negative size'
      end

      current_size = enumerator_size
      set_size     = if Integer === current_size
                       n < current_size ? n : current_size
                     else
                       current_size
                     end

      taken = 0
      Lazy.new(self, set_size) do |enum, *args|
        if taken < n
          enum.yield(*args)
          taken += 1
        else
          raise StopLazyError
        end
      end
    end

    def take_while(&block)
      unless block
        raise ArgumentError, 'tried to call lazy take_while without a block'
      end

      Lazy.new(self, nil) do |enum, *args|
        %x{
          var value = Opal.yieldX(block, args);

          if (#{Opal.truthy?(`value`)}) {
            #{enum.yield(*args)};
          }
          else {
            #{raise StopLazyError};
          }
        }
      end
    end

    alias to_enum enum_for

    def inspect
      "#<#{self.class}: #{@enumerator.inspect}>"
    end
  end
end
