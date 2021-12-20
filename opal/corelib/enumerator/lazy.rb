# helpers: truthy, coerce_to, yield1, yieldX

class ::Enumerator
  class self::Lazy < self
    class self::StopLazyError < ::Exception; end

    def self.for(object, *)
      lazy = super
      `lazy.enumerator = object`
      lazy
    end

    def initialize(object, size = nil, &block)
      unless block_given?
        ::Kernel.raise ::ArgumentError, 'tried to call lazy new without a block'
      end

      @enumerator = object

      super size do |yielder, *each_args|
        object.each(*each_args) do |*args|
          %x{
            args.unshift(#{yielder});

            $yieldX(block, args);
          }
        end
      rescue StopLazyError
        nil
      end
    end

    def lazy
      self
    end

    def collect(&block)
      unless block
        ::Kernel.raise ::ArgumentError, 'tried to call lazy map without a block'
      end

      Lazy.new(self, enumerator_size) do |enum, *args|
        %x{
          var value = $yieldX(block, args);

          #{enum.yield `value`};
        }
      end
    end

    def collect_concat(&block)
      unless block
        ::Kernel.raise ::ArgumentError, 'tried to call lazy map without a block'
      end

      Lazy.new(self, nil) do |enum, *args|
        %x{
          var value = $yieldX(block, args);

          if (#{`value`.respond_to? :force} && #{`value`.respond_to? :each}) {
            #{`value`.each { |v| enum.yield v }}
          }
          else {
            var array = #{::Opal.try_convert `value`, ::Array, :to_ary};

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
      n = `$coerce_to(#{n}, #{::Integer}, 'to_int')`

      if n < 0
        ::Kernel.raise ::ArgumentError, 'attempt to drop negative size'
      end

      current_size = enumerator_size
      set_size     = if ::Integer === current_size
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
        ::Kernel.raise ::ArgumentError, 'tried to call lazy drop_while without a block'
      end

      succeeding = true
      Lazy.new(self, nil) do |enum, *args|
        if succeeding
          %x{
            var value = $yieldX(block, args);

            if (!$truthy(value)) {
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
        ::Kernel.raise ::ArgumentError, 'tried to call lazy select without a block'
      end

      Lazy.new(self, nil) do |enum, *args|
        %x{
          var value = $yieldX(block, args);

          if ($truthy(value)) {
            #{enum.yield(*args)};
          }
        }
      end
    end

    def grep(pattern, &block)
      if block
        Lazy.new(self, nil) do |enum, *args|
          %x{
            var param = #{::Opal.destructure(args)},
                value = #{pattern === `param`};

            if ($truthy(value)) {
              value = $yield1(block, param);

              #{enum.yield `$yield1(block, param)`};
            }
          }
        end
      else
        Lazy.new(self, nil) do |enum, *args|
          %x{
            var param = #{::Opal.destructure(args)},
                value = #{pattern === `param`};

            if ($truthy(value)) {
              #{enum.yield `param`};
            }
          }
        end
      end
    end

    def reject(&block)
      unless block
        ::Kernel.raise ::ArgumentError, 'tried to call lazy reject without a block'
      end

      Lazy.new(self, nil) do |enum, *args|
        %x{
          var value = $yieldX(block, args);

          if (!$truthy(value)) {
            #{enum.yield(*args)};
          }
        }
      end
    end

    def take(n)
      n = `$coerce_to(#{n}, #{::Integer}, 'to_int')`

      if n < 0
        ::Kernel.raise ::ArgumentError, 'attempt to take negative size'
      end

      current_size = enumerator_size
      set_size     = if ::Integer === current_size
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
          ::Kernel.raise StopLazyError
        end
      end
    end

    def take_while(&block)
      unless block
        ::Kernel.raise ::ArgumentError, 'tried to call lazy take_while without a block'
      end

      Lazy.new(self, nil) do |enum, *args|
        %x{
          var value = $yieldX(block, args);

          if ($truthy(value)) {
            #{enum.yield(*args)};
          }
          else {
            #{::Kernel.raise StopLazyError};
          }
        }
      end
    end

    def inspect
      "#<#{self.class}: #{@enumerator.inspect}>"
    end

    alias force to_a
    alias filter find_all
    alias flat_map collect_concat
    alias map collect
    alias select find_all
    alias to_enum enum_for
  end
end
