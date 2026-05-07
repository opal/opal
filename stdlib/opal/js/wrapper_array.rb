# backtick_javascript: true

module ::Opal
  module JS
    class << self
      def array_push(native, value)
        %x{
          if (typeof #{native}.push === 'function') return #{native}.push(#{to_js(value)});
          #{native}[#{native}.length] = #{to_js(value)};
          #{native}.length += 1;
          return #{native}.length;
        }
      end

      def array_pop(native)
        %x{
          var value;
          if (typeof #{native}.pop === 'function') return #{from_js(`#{native}.pop()`)};
          if (#{native}.length <= 0) return nil;
          value = #{native}[#{native}.length - 1];
          delete #{native}[#{native}.length - 1];
          #{native}.length -= 1;
          return #{from_js(`value`)};
        }
      end

      def array_shift(native)
        %x{
          var value;
          if (typeof #{native}.shift === 'function') return #{from_js(`#{native}.shift()`)};
          if (#{native}.length <= 0) return nil;
          value = #{native}[0];
          for (var i = 1; i < #{native}.length; i++) #{native}[i - 1] = #{native}[i];
          delete #{native}[#{native}.length - 1];
          #{native}.length -= 1;
          return #{from_js(`value`)};
        }
      end

      def array_unshift(native, value)
        %x{
          if (typeof #{native}.unshift === 'function') return #{native}.unshift(#{to_js(value)});
          for (var i = #{native}.length; i > 0; i--) #{native}[i] = #{native}[i - 1];
          #{native}[0] = #{to_js(value)};
          #{native}.length += 1;
          return #{native}.length;
        }
      end
    end
  end
end
