class ::Random
  module self::Formatter
    def hex(count = nil)
      count = ::Random._verify_count(count)
      %x{
        var bytes = #{bytes(count)};
        var out = "";
        for (var i = 0; i < #{count}; i++) {
          out += bytes.charCodeAt(i).toString(16).padStart(2, '0');
        }
        return #{`out`.encode('US-ASCII')};
      }
    end

    def random_bytes(count = nil)
      bytes(count)
    end

    def base64(count = nil)
      ::Base64.strict_encode64(random_bytes(count)).encode('US-ASCII')
    end

    def urlsafe_base64(count = nil, padding = false)
      ::Base64.urlsafe_encode64(random_bytes(count), padding).encode('US-ASCII')
    end

    def uuid
      str = hex(16).split('')
      str[12] = '4'
      str[16] = `(parseInt(#{str[16]}, 16) & 3 | 8).toString(16)`
      str = [str[0...8], str[8...12], str[12...16], str[16...20], str[20...32]]
      str = str.map(&:join)
      str.join('-')
    end

    # Implemented in terms of `#bytes` for SecureRandom, but Random overrides this
    # method to implement `#bytes` in terms of `#random_float`. Not part of standard
    # Ruby interface - use random_number for portability.
    def random_float
      bs = bytes(4)
      num = 0
      4.times do |i|
        num <<= 8
        num |= bs[i].ord
      end
      num.abs / 0x7fffffff
    end

    def random_number(limit = undefined)
      %x{
        function randomFloat() {
          return #{random_float};
        }

        function randomInt(max) {
          return Math.floor(randomFloat() * max);
        }

        function randomRange() {
          var min = limit.begin,
              max = limit.end;

          if (min === nil || max === nil) {
            return nil;
          }

          var length = max - min;

          if (length < 0) {
            return nil;
          }

          if (length === 0) {
            return min;
          }

          if (max % 1 === 0 && min % 1 === 0 && !limit.excl) {
            length++;
          }

          return randomInt(length) + min;
        }

        if (limit == null) {
          return randomFloat();
        } else if (limit.$$is_range) {
          return randomRange();
        } else if (limit.$$is_number) {
          if (limit <= 0) {
            #{::Kernel.raise ::ArgumentError, "invalid argument - #{limit}"}
          }

          if (limit % 1 === 0) {
            // integer
            return randomInt(limit);
          } else {
            return randomFloat() * limit;
          }
        } else {
          limit = #{::Opal.coerce_to!(limit, ::Integer, :to_int)};

          if (limit <= 0) {
            #{::Kernel.raise ::ArgumentError, "invalid argument - #{limit}"}
          }

          return randomInt(limit);
        }
      }
    end

    def alphanumeric(count = nil)
      count = Random._verify_count(count)
      map = ['0'..'9', 'a'..'z', 'A'..'Z'].map(&:to_a).flatten
      ::Array.new(count) do |i|
        map[random_number(map.length)]
      end.join
    end
  end

  include ::Random::Formatter
  extend ::Random::Formatter
end
