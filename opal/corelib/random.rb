class Random
  attr_reader :seed, :state

  def initialize(seed = Random.new_seed)
    seed = Opal.coerce_to!(seed, Integer, :to_int)
    @state = seed
    reseed(seed)
  end

  def reseed(seed)
    @seed = seed
    `self.$rng = Opal.$$rand.reseed(seed)`
  end

  def self.new_seed
    `Opal.$$rand.new_seed()`
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

  def self.urandom(size)
    size = Opal.coerce_to!(size, Integer, :to_int)

    if size < 0
      raise ArgumentError, 'negative string size (or size too big)'
    end

    Array.new(size) { rand(255).chr }.join.encode('ASCII-8BIT')
  end

  def ==(other)
    return false unless Random === other

    seed == other.seed && state == other.state
  end

  def bytes(length)
    length = Opal.coerce_to!(length, Integer, :to_int)

    Array.new(length) { rand(255).chr }.join.encode('ASCII-8BIT')
  end

  def rand(limit = undefined)
    %x{
      function randomFloat() {
        self.state++;
        return Opal.$$rand.rand(self.$rng);
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

        if (max % 1 === 0 && min % 1 === 0 && !limit.excl) {
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

  def self.generator=(generator)
    `Opal.$$rand = #{generator}`

    if const_defined? :DEFAULT
      DEFAULT.reseed
    else
      const_set :DEFAULT, new(new_seed)
    end
  end
end
