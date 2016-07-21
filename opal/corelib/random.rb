require 'corelib/random/seedrandom.js'

class Random
  attr_reader :seed, :state

  def initialize(seed = Random.new_seed)
    seed = Opal.coerce_to!(seed, Integer, :to_int)
    @state = seed
    reseed(seed)
  end

  def reseed(seed)
    @seed = seed
    `self.$rng = new Math.seedrandom(seed);`
  end

  `var $seed_generator = new Math.seedrandom('opal', { entropy: true });`

  def self.new_seed
    %x{
      return Math.abs($seed_generator.int32());
    }
  end

  def self.rand(limit = undefined)
    DEFAULT.rand(limit)
  end


  def self.srand(n = Random.new_seed)
    n = Opal.coerce_to!(n, Integer, :to_int)

    previous_seed = DEFAULT.seed
    DEFAULT.reseed(n)
    previous_seed
  end

  DEFAULT = new(new_seed)

  def ==(other)
    return false unless Random === other

    seed == other.seed && state == other.state
  end

  def bytes(length)
    length = Opal.coerce_to!(length, Integer, :to_int)
    length
      .times
      .map { rand(255).chr }
      .join
      .encode(Encoding::ASCII_8BIT)
  end

  def rand(limit = undefined)
    %x{
      function randomFloat() {
        self.state++;
        return self.$rng.quick();
      }

      function randomInt() {
        return Math.floor(randomFloat() * limit);
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

        if (max % 1 === 0 && min % 1 === 0 && !limit.exclude) {
          length++;
        }

        return self.$rand(length) + min;
      }

      if (limit == null) {
        return randomFloat();
      } else if (limit.$$is_range) {
        return randomRange();
      } else if (limit.$$is_number) {
        if (limit <= 0) {
          #{raise ArgumentError, "invalid argument - #{limit}"}
        }

        if (limit % 1 === 0) {
          // integer
          return randomInt();
        } else {
          return randomFloat() * limit;
        }
      } else {
        limit = #{Opal.coerce_to!(limit, Integer, :to_int)};

        if (limit <= 0) {
          #{raise ArgumentError, "invalid argument - #{limit}"}
        }

        return randomInt();
      }
    }
  end
end
